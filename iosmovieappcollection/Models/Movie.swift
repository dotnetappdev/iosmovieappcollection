//
//  Movie.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import Foundation
import SwiftData

@Model
final class Movie {
    var id: String
    var title: String
    var year: Int?
    var director: String?
    var plot: String?
    var genre: String?
    var imdbID: String?
    var posterURL: String?
    var posterImageData: Data?
    var barcode: String?
    var dateAdded: Date
    var isWanted: Bool
    var userRating: Int? // 1-10 scale
    var runtime: String?
    var actors: String?
    var language: String?
    var country: String?
    var awards: String?
    @Relationship(inverse: \Collection.movies) var collections: [Collection]?
    
    init(
        id: String = UUID().uuidString,
        title: String,
        year: Int? = nil,
        director: String? = nil,
        plot: String? = nil,
        genre: String? = nil,
        imdbID: String? = nil,
        posterURL: String? = nil,
        posterImageData: Data? = nil,
        barcode: String? = nil,
        dateAdded: Date = Date(),
        isWanted: Bool = false,
        userRating: Int? = nil,
        runtime: String? = nil,
        actors: String? = nil,
        language: String? = nil,
        country: String? = nil,
        awards: String? = nil
    ) {
        self.id = id
        self.title = title
        self.year = year
        self.director = director
        self.plot = plot
        self.genre = genre
        self.imdbID = imdbID
        self.posterURL = posterURL
        self.posterImageData = posterImageData
        self.barcode = barcode
        self.dateAdded = dateAdded
        self.isWanted = isWanted
        self.userRating = userRating
        self.runtime = runtime
        self.actors = actors
        self.language = language
        self.country = country
        self.awards = awards
    }
}

// MARK: - Computed Properties
extension Movie {
    var hasLocalPoster: Bool {
        posterImageData != nil
    }
    
    var displayYear: String {
        guard let year = year else { return "Unknown" }
        return String(year)
    }
    
    var displayGenre: String {
        genre?.isEmpty == false ? genre! : "Unknown"
    }
    
    var displayRating: String {
        guard let rating = userRating else { return "Not Rated" }
        return "\(rating)/10"
    }
}