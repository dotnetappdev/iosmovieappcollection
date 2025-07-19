//
//  iosmovieappcollectionTests.swift
//  iosmovieappcollectionTests
//
//  Created by david on 19/07/2025.
//

import Testing
import AVFoundation
import Photos
@testable import iosmovieappcollection

struct iosmovieappcollectionTests {

    @Test func testMovieCreation() async throws {
        // Test that we can create a movie with basic properties
        let movie = Movie(
            title: "Test Movie",
            year: 2023,
            director: "Test Director",
            genre: "Action"
        )
        
        #expect(movie.title == "Test Movie")
        #expect(movie.year == 2023)
        #expect(movie.director == "Test Director")
        #expect(movie.genre == "Action")
        #expect(movie.isWanted == false) // default value
        #expect(movie.displayYear == "2023")
        #expect(movie.displayGenre == "Action")
    }
    
    @Test func testCollectionCreation() async throws {
        // Test that we can create a collection
        let collection = Collection(
            name: "Test Collection",
            collectionDescription: "A test collection",
            color: "#FF6B6B",
            iconName: "folder.fill"
        )
        
        #expect(collection.name == "Test Collection")
        #expect(collection.displayDescription == "A test collection")
        #expect(collection.color == "#FF6B6B")
        #expect(collection.displayIcon == "folder.fill")
        #expect(collection.movieCount == 0) // no movies yet
    }
    
    @Test func testDefaultCollections() async throws {
        // Test that default collections are created correctly
        let defaultCollections = Collection.createDefaultCollections()
        
        #expect(defaultCollections.count == 6)
        #expect(defaultCollections.contains { $0.name == "Action" })
        #expect(defaultCollections.contains { $0.name == "Comedy" })
        #expect(defaultCollections.contains { $0.name == "Drama" })
        #expect(defaultCollections.contains { $0.name == "Horror" })
        #expect(defaultCollections.contains { $0.name == "Sci-Fi" })
        #expect(defaultCollections.contains { $0.name == "Romance" })
    }
    
    @Test func testAppSettings() async throws {
        // Test that app settings work correctly
        let settings = AppSettings()
        
        // Test defaults
        #expect(settings.imdbAPIBaseURL == "https://www.omdbapi.com/")
        #expect(settings.autoSaveToPhotos == false)
        #expect(settings.defaultMovieRating == 5)
        #expect(settings.enableBarcodeSound == true)
        #expect(settings.showMovieCount == true)
        #expect(settings.isAPIConfigured == false) // no API key set
        
        // Test setting API key
        settings.imdbAPIKey = "testkey123"
        #expect(settings.hasValidAPIKey == true)
        #expect(settings.isAPIConfigured == true)
    }
    
    @Test func testIMDBResponseParsing() async throws {
        // Test IMDB API response parsing
        let sampleJSON = """
        {
            "Title": "The Matrix",
            "Year": "1999",
            "Genre": "Action, Sci-Fi",
            "Director": "Lana Wachowski, Lilly Wachowski",
            "Plot": "A computer programmer is led to fight an underground war.",
            "Response": "True",
            "imdbID": "tt0133093"
        }
        """.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(IMDBResponse.self, from: sampleJSON)
        
        #expect(response.title == "The Matrix")
        #expect(response.year == "1999")
        #expect(response.genre == "Action, Sci-Fi")
        #expect(response.director == "Lana Wachowski, Lilly Wachowski")
        #expect(response.response == "True")
        #expect(response.imdbID == "tt0133093")
    }
    
    @Test func testMovieFromIMDBResponse() async throws {
        // Test creating a movie from IMDB response
        let response = IMDBResponse(
            title: "Test Movie",
            year: "2023",
            rated: "PG-13",
            released: "01 Jan 2023",
            runtime: "120 min",
            genre: "Action",
            director: "Test Director",
            writer: "Test Writer",
            actors: "Test Actor 1, Test Actor 2",
            plot: "A test movie plot",
            language: "English",
            country: "USA",
            awards: "N/A",
            poster: "http://example.com/poster.jpg",
            imdbID: "tt1234567",
            imdbRating: "8.5",
            response: "True",
            error: nil
        )
        
        let imdbService = IMDBService()
        let movie = imdbService.createMovieFromIMDBResponse(response)
        
        #expect(movie.title == "Test Movie")
        #expect(movie.year == 2023)
        #expect(movie.genre == "Action")
        #expect(movie.director == "Test Director")
        #expect(movie.plot == "A test movie plot")
        #expect(movie.imdbID == "tt1234567")
        #expect(movie.posterURL == "http://example.com/poster.jpg")
        #expect(movie.runtime == "120 min")
        #expect(movie.actors == "Test Actor 1, Test Actor 2")
        #expect(movie.language == "English")
        #expect(movie.country == "USA")
    }
    
    @Test func testPermissionsService() async throws {
        // Test permissions service initialization
        let permissionsService = PermissionsService()
        
        // Should initialize with current system status
        #expect(permissionsService.cameraPermissionStatus == AVCaptureDevice.authorizationStatus(for: .video))
        #expect(permissionsService.photoLibraryPermissionStatus == PHPhotoLibrary.authorizationStatus(for: .addOnly))
        
        // Test permission descriptions
        let cameraDescription = permissionsService.cameraPermissionDescription
        let photoDescription = permissionsService.photoLibraryPermissionDescription
        
        #expect(!cameraDescription.isEmpty)
        #expect(!photoDescription.isEmpty)
    }
    
    @Test func testImageCacheService() async throws {
        // Test image cache service
        let imageCache = ImageCacheService()
        
        // Test cache size calculation
        let cacheSize = imageCache.getCacheSize()
        #expect(!cacheSize.isEmpty)
        #expect(cacheSize.contains("MB"))
        
        // Test cache operations with sample data
        let sampleData = "test image data".data(using: .utf8)!
        let testURL = "http://example.com/test.jpg"
        
        // Cache the data
        imageCache.cacheImage(data: sampleData, for: testURL)
        
        // Retrieve from cache
        let cachedData = imageCache.getCachedImage(for: testURL)
        #expect(cachedData == sampleData)
        
        // Clear cache
        imageCache.clearCache()
        let clearedData = imageCache.getCachedImage(for: testURL)
        #expect(clearedData == nil)
    }
    
    @Test func testMovieDisplayProperties() async throws {
        // Test movie computed properties
        let movieWithData = Movie(
            title: "Complete Movie",
            year: 2023,
            genre: "Action",
            userRating: 8
        )
        
        #expect(movieWithData.displayYear == "2023")
        #expect(movieWithData.displayGenre == "Action")
        #expect(movieWithData.displayRating == "8/10")
        #expect(movieWithData.hasLocalPoster == false)
        
        let movieWithoutData = Movie(title: "Incomplete Movie")
        
        #expect(movieWithoutData.displayYear == "Unknown")
        #expect(movieWithoutData.displayGenre == "Unknown")
        #expect(movieWithoutData.displayRating == "Not Rated")
        
        // Test with poster data
        let posterData = "poster".data(using: .utf8)!
        movieWithData.posterImageData = posterData
        #expect(movieWithData.hasLocalPoster == true)
    }
    
    @Test func testAppSettingsValidation() async throws {
        // Test app settings validation
        let settings = AppSettings()
        
        // Initially not configured
        #expect(settings.isAPIConfigured == false)
        #expect(settings.hasValidAPIKey == false)
        
        // Set short API key
        settings.imdbAPIKey = "short"
        #expect(settings.hasValidAPIKey == false)
        
        // Set valid API key
        settings.imdbAPIKey = "validapikey123"
        #expect(settings.hasValidAPIKey == true)
        #expect(settings.isAPIConfigured == true)
        
        // Test reset
        settings.resetToDefaults()
        #expect(settings.imdbAPIKey.isEmpty)
        #expect(settings.isAPIConfigured == false)
    }

}
