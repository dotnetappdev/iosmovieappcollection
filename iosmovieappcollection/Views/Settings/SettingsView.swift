//
//  SettingsView.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var showingAPIKeyAlert = false
    @State private var tempAPIKey = ""
    
    var body: some View {
        NavigationView {
            Form {
                // API Configuration Section
                Section("API Configuration") {
                    HStack {
                        Label("IMDB API Key", systemImage: "key.fill")
                        Spacer()
                        if appSettings.hasValidAPIKey {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.orange)
                        }
                        Button("Configure") {
                            tempAPIKey = appSettings.imdbAPIKey
                            showingAPIKeyAlert = true
                        }
                        .foregroundColor(.accentColor)
                    }
                    
                    HStack {
                        Label("API Endpoint", systemImage: "network")
                        Spacer()
                        Text(appSettings.imdbAPIBaseURL.isEmpty ? "Not Set" : "Configured")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                // App Preferences Section
                Section("Preferences") {
                    Toggle(isOn: $appSettings.autoSaveToPhotos) {
                        Label("Auto-save Posters", systemImage: "photo.on.rectangle.angled")
                    }
                    
                    Toggle(isOn: $appSettings.enableBarcodeSound) {
                        Label("Barcode Scan Sound", systemImage: "speaker.wave.2.fill")
                    }
                    
                    Toggle(isOn: $appSettings.showMovieCount) {
                        Label("Show Movie Count", systemImage: "number.circle.fill")
                    }
                    
                    HStack {
                        Label("Default Rating", systemImage: "star.fill")
                        Spacer()
                        Picker("Default Rating", selection: $appSettings.defaultMovieRating) {
                            ForEach(1...10, id: \.self) { rating in
                                Text("\(rating)")
                                    .tag(rating)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // Storage Section
                Section("Storage") {
                    NavigationLink(destination: StorageManagementView()) {
                        Label("Manage Storage", systemImage: "internaldrive.fill")
                    }
                    
                    NavigationLink(destination: DataExportView()) {
                        Label("Export Data", systemImage: "square.and.arrow.up.fill")
                    }
                }
                
                // About Section
                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle.fill")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        Label("About App", systemImage: "questionmark.circle.fill")
                    }
                    
                    Button(action: {
                        // Open privacy policy
                    }) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                }
                
                // Reset Section
                Section("Reset") {
                    Button(action: {
                        appSettings.resetToDefaults()
                    }) {
                        Label("Reset Settings", systemImage: "arrow.clockwise.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .alert("Configure API Key", isPresented: $showingAPIKeyAlert) {
            TextField("IMDB API Key", text: $tempAPIKey)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                appSettings.imdbAPIKey = tempAPIKey
            }
        } message: {
            Text("Enter your IMDB API key to enable movie metadata fetching. You can get a free API key from www.omdbapi.com")
        }
    }
}

struct StorageManagementView: View {
    @StateObject private var imageCache = ImageCacheService()
    @State private var cacheSize = "Calculating..."
    @State private var isClearing = false
    
    var body: some View {
        List {
            Section("Cache") {
                HStack {
                    Label("Image Cache", systemImage: "photo.stack.fill")
                    Spacer()
                    Text(cacheSize)
                        .foregroundColor(.secondary)
                    Button("Clear") {
                        clearCache()
                    }
                    .foregroundColor(.red)
                    .disabled(isClearing)
                }
                
                HStack {
                    Label("Database Size", systemImage: "externaldrive.fill")
                    Spacer()
                    Text("N/A")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Photo Albums") {
                NavigationLink(destination: PhotoAlbumSettingsView()) {
                    Label("Manage Albums", systemImage: "rectangle.stack.fill")
                }
            }
            
            Section("Actions") {
                Button(action: {
                    // Clear all data
                }) {
                    Label("Clear All Data", systemImage: "trash.fill")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Storage")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadCacheSize()
        }
    }
    
    private func loadCacheSize() {
        Task {
            let size = imageCache.getCacheSize()
            await MainActor.run {
                cacheSize = size
            }
        }
    }
    
    private func clearCache() {
        isClearing = true
        
        Task {
            imageCache.clearCache()
            await MainActor.run {
                cacheSize = "0 MB"
                isClearing = false
            }
        }
    }
}

struct DataExportView: View {
    var body: some View {
        List {
            Section("Export Options") {
                Button(action: {
                    // Export as JSON
                }) {
                    Label("Export as JSON", systemImage: "doc.text.fill")
                }
                
                Button(action: {
                    // Export as CSV
                }) {
                    Label("Export as CSV", systemImage: "tablecells.fill")
                }
                
                Button(action: {
                    // Share collection
                }) {
                    Label("Share Collection", systemImage: "square.and.arrow.up.fill")
                }
            }
            
            Section("Import") {
                Button(action: {
                    // Import from file
                }) {
                    Label("Import Collection", systemImage: "square.and.arrow.down.fill")
                }
            }
        }
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PhotoAlbumSettingsView: View {
    @StateObject private var photoService = PhotoLibraryService()
    @State private var isCreatingAlbums = false
    @State private var isSyncing = false
    @State private var albumStats: (collected: Int, wanted: Int) = (0, 0)
    @State private var showingPermissionAlert = false
    
    var body: some View {
        List {
            Section("Photo Library Albums") {
                HStack {
                    Label("Movies Collected", systemImage: "checkmark.circle.fill")
                    Spacer()
                    Text("\(albumStats.collected) photos")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                HStack {
                    Label("Movies Wanted", systemImage: "heart.fill")
                    Spacer()
                    Text("\(albumStats.wanted) photos")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            Section("Permissions") {
                HStack {
                    Label("Photo Library Access", systemImage: "photo.fill")
                    Spacer()
                    Text(photoService.authorizationStatus.description)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                if photoService.authorizationStatus != .authorized && photoService.authorizationStatus != .limited {
                    Button("Request Permission") {
                        Task {
                            let granted = await photoService.requestPhotoLibraryPermission()
                            if !granted {
                                showingPermissionAlert = true
                            }
                        }
                    }
                    .foregroundColor(.accentColor)
                }
            }
            
            Section("Actions") {
                Button(action: {
                    createAlbums()
                }) {
                    HStack {
                        Label("Create Albums", systemImage: "plus.circle.fill")
                        if isCreatingAlbums {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                .disabled(isCreatingAlbums || (photoService.authorizationStatus != .authorized && photoService.authorizationStatus != .limited))
                
                Button(action: {
                    syncPosters()
                }) {
                    HStack {
                        Label("Sync All Posters", systemImage: "arrow.clockwise.circle.fill")
                        if isSyncing {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                .disabled(isSyncing || (photoService.authorizationStatus != .authorized && photoService.authorizationStatus != .limited))
            }
        }
        .navigationTitle("Photo Albums")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadAlbumStats()
        }
        .alert("Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Photo library access is required to save movie posters. Please enable it in Settings.")
        }
    }
    
    private func createAlbums() {
        isCreatingAlbums = true
        
        Task {
            do {
                try await photoService.createMovieAlbums()
                await loadAlbumStats()
            } catch {
                print("Failed to create albums: \(error)")
            }
            
            await MainActor.run {
                isCreatingAlbums = false
            }
        }
    }
    
    private func syncPosters() {
        isSyncing = true
        
        Task {
            // This would sync all movie posters - requires access to movie data
            // For now, just simulate the process
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await loadAlbumStats()
            
            await MainActor.run {
                isSyncing = false
            }
        }
    }
    
    private func loadAlbumStats() {
        Task {
            let stats = await photoService.getAlbumStatistics()
            await MainActor.run {
                albumStats = stats
            }
        }
    }
}

extension PHAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined:
            return "Not Requested"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorized:
            return "Full Access"
        case .limited:
            return "Limited Access"
        @unknown default:
            return "Unknown"
        }
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(spacing: 16) {
                    Image(systemName: "film.stack.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("Movie Collection Manager")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("About")
                        .font(.headline)
                    
                    Text("A personal movie collection app for iOS, built in Swift using SwiftData, with support for barcode scanning, IMDB lookup, image storage, and genre-based organization.")
                        .font(.body)
                    
                    Text("Features")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureRow(icon: "barcode.viewfinder", text: "Barcode scanning for UK DVDs")
                        FeatureRow(icon: "network", text: "IMDB integration for metadata")
                        FeatureRow(icon: "photo.fill", text: "Automatic poster storage")
                        FeatureRow(icon: "folder.fill", text: "Custom collections and genres")
                        FeatureRow(icon: "magnifyingglass", text: "Fast local search")
                        FeatureRow(icon: "moon.fill", text: "Dark and Light mode support")
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            Text(text)
                .font(.body)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppSettings())
    }
}