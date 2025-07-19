//
//  iosmovieappcollectionTests.swift
//  iosmovieappcollectionTests
//
//  Created by david on 19/07/2025.
//

import Testing
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

}
