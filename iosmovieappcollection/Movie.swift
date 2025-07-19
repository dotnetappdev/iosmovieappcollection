//
//  Movie.swift
//  iosmovieappcollection
//
//  Enhanced with Movie model for collection
//

import Foundation
import SwiftData

@Model
final class Movie {
    var id: Int
    var title: String
    var overview: String
    var posterPath: String?
    var releaseDate: String
    var voteAverage: Double
    var dateAdded: Date
    var barcode: String?
    
    init(id: Int, title: String, overview: String, posterPath: String? = nil, releaseDate: String, voteAverage: Double, barcode: String? = nil) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.dateAdded = Date()
        self.barcode = barcode
    }
    
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    var formattedReleaseDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: releaseDate) else { return releaseDate }
        
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - API Response Models
struct MovieSearchResponse: Codable {
    let results: [MovieAPIResponse]
}

struct MovieAPIResponse: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String
    let voteAverage: Double
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }
    
    func toMovie() -> Movie {
        return Movie(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage
        )
    }
}