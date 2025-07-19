//
//  PhotoLibraryService.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import Foundation
import Photos
import SwiftUI

// MARK: - Photo Library Service
@MainActor
class PhotoLibraryService: ObservableObject {
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    private let collectedAlbumName = "Movies Collected"
    private let wantedAlbumName = "Movies Wanted"
    
    enum PhotoError: LocalizedError {
        case permissionDenied
        case albumCreationFailed
        case saveFailed
        case imageDataInvalid
        
        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Photo library access denied"
            case .albumCreationFailed:
                return "Failed to create photo album"
            case .saveFailed:
                return "Failed to save image to photo library"
            case .imageDataInvalid:
                return "Invalid image data"
            }
        }
    }
    
    init() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
    }
    
    // MARK: - Permission Management
    func requestPhotoLibraryPermission() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        authorizationStatus = status
        
        switch status {
        case .authorized, .limited:
            return true
        case .denied, .restricted, .notDetermined:
            return false
        @unknown default:
            return false
        }
    }
    
    // MARK: - Album Management
    private func findAlbum(named albumName: String) async -> PHAssetCollection? {
        let albums = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .albumRegular,
            options: nil
        )
        
        for i in 0..<albums.count {
            let album = albums.object(at: i)
            if album.localizedTitle == albumName {
                return album
            }
        }
        
        return nil
    }
    
    private func createAlbum(named albumName: String) async throws -> PHAssetCollection {
        return try await withCheckedThrowingContinuation { continuation in
            var albumPlaceholder: PHObjectPlaceholder?
            
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { success, error in
                if success, let placeholder = albumPlaceholder {
                    let albums = PHAssetCollection.fetchAssetCollections(
                        withLocalIdentifiers: [placeholder.localIdentifier],
                        options: nil
                    )
                    if let album = albums.firstObject {
                        continuation.resume(returning: album)
                    } else {
                        continuation.resume(throwing: PhotoError.albumCreationFailed)
                    }
                } else {
                    continuation.resume(throwing: error ?? PhotoError.albumCreationFailed)
                }
            })
        }
    }
    
    private func getOrCreateAlbum(named albumName: String) async throws -> PHAssetCollection {
        if let existingAlbum = await findAlbum(named: albumName) {
            return existingAlbum
        } else {
            return try await createAlbum(named: albumName)
        }
    }
    
    // MARK: - Image Saving
    func savePosterToPhotoLibrary(imageData: Data, movieTitle: String, isWanted: Bool) async throws {
        // Check permissions
        guard authorizationStatus == .authorized || authorizationStatus == .limited else {
            let granted = await requestPhotoLibraryPermission()
            if !granted {
                throw PhotoError.permissionDenied
            }
        }
        
        // Validate image data
        guard UIImage(data: imageData) != nil else {
            throw PhotoError.imageDataInvalid
        }
        
        // Determine album name
        let albumName = isWanted ? wantedAlbumName : collectedAlbumName
        
        // Get or create album
        let album = try await getOrCreateAlbum(named: albumName)
        
        // Save image to album
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            var assetPlaceholder: PHObjectPlaceholder?
            
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: imageData, options: nil)
                assetPlaceholder = creationRequest.placeholderForCreatedAsset
                
                // Add to album
                guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
                      let placeholder = assetPlaceholder else { return }
                
                albumChangeRequest.addAssets([placeholder] as NSArray)
                
            }, completionHandler: { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: error ?? PhotoError.saveFailed)
                }
            })
        }
    }
    
    // MARK: - Bulk Operations
    func createMovieAlbums() async throws {
        // Check permissions first
        guard authorizationStatus == .authorized || authorizationStatus == .limited else {
            let granted = await requestPhotoLibraryPermission()
            if !granted {
                throw PhotoError.permissionDenied
            }
        }
        
        // Create both albums
        _ = try await getOrCreateAlbum(named: collectedAlbumName)
        _ = try await getOrCreateAlbum(named: wantedAlbumName)
    }
    
    func syncAllMoviePosters(movies: [Movie]) async {
        for movie in movies {
            guard let posterData = movie.posterImageData else { continue }
            
            do {
                try await savePosterToPhotoLibrary(
                    imageData: posterData,
                    movieTitle: movie.title,
                    isWanted: movie.isWanted
                )
            } catch {
                print("Failed to sync poster for \(movie.title): \(error)")
            }
        }
    }
    
    // MARK: - Album Statistics
    func getAlbumStatistics() async -> (collected: Int, wanted: Int) {
        var collectedCount = 0
        var wantedCount = 0
        
        if let collectedAlbum = await findAlbum(named: collectedAlbumName) {
            let assets = PHAsset.fetchAssets(in: collectedAlbum, options: nil)
            collectedCount = assets.count
        }
        
        if let wantedAlbum = await findAlbum(named: wantedAlbumName) {
            let assets = PHAsset.fetchAssets(in: wantedAlbum, options: nil)
            wantedCount = assets.count
        }
        
        return (collected: collectedCount, wanted: wantedCount)
    }
}

// MARK: - Image Cache Service
@MainActor
class ImageCacheService: ObservableObject {
    private let cache = NSCache<NSString, NSData>()
    private let session = URLSession.shared
    
    private var cacheDirectory: URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("MoviePosters")
    }
    
    init() {
        // Configure cache
        cache.countLimit = 100 // Maximum 100 images in memory
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB limit
        
        // Create cache directory
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Cache Operations
    func getCachedImage(for url: String) -> Data? {
        let key = NSString(string: url)
        return cache.object(forKey: key) as Data?
    }
    
    func cacheImage(data: Data, for url: String) {
        let key = NSString(string: url)
        cache.setObject(NSData(data: data), forKey: key)
        
        // Also save to disk
        let fileName = url.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        try? data.write(to: fileURL)
    }
    
    func loadImageFromDisk(for url: String) -> Data? {
        let fileName = url.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        return try? Data(contentsOf: fileURL)
    }
    
    func downloadAndCacheImage(from urlString: String) async -> Data? {
        // Check memory cache first
        if let cachedData = getCachedImage(for: urlString) {
            return cachedData
        }
        
        // Check disk cache
        if let diskData = loadImageFromDisk(for: urlString) {
            cacheImage(data: diskData, for: urlString)
            return diskData
        }
        
        // Download from network
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await session.data(from: url)
            cacheImage(data: data, for: urlString)
            return data
        } catch {
            print("Failed to download image: \(error)")
            return nil
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func getCacheSize() -> String {
        guard let enumerator = FileManager.default.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return "0 MB"
        }
        
        var totalSize: Int64 = 0
        
        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                  let fileSize = resourceValues.fileSize else { continue }
            totalSize += Int64(fileSize)
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalSize)
    }
}