//
//  MovieService.swift
//  iosmovieappcollection
//
//  Enhanced networking service using Alamofire
//

import Foundation
import Alamofire

class MovieService: ObservableObject {
    static let shared = MovieService()
    
    // Note: In a real app, this should be stored securely and not hardcoded
    private let apiKey = "your_tmdb_api_key_here"
    private let baseURL = "https://api.themoviedb.org/3"
    
    private init() {}
    
    func searchMovies(query: String) async throws -> [MovieAPIResponse] {
        guard !query.isEmpty else { return [] }
        
        let parameters: [String: Any] = [
            "api_key": apiKey,
            "query": query,
            "page": 1
        ]
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request("\(baseURL)/search/movie", parameters: parameters)
                .validate()
                .responseDecodable(of: MovieSearchResponse.self) { response in
                    switch response.result {
                    case .success(let movieResponse):
                        continuation.resume(returning: movieResponse.results)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    func getPopularMovies() async throws -> [MovieAPIResponse] {
        let parameters: [String: Any] = [
            "api_key": apiKey,
            "page": 1
        ]
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request("\(baseURL)/movie/popular", parameters: parameters)
                .validate()
                .responseDecodable(of: MovieSearchResponse.self) { response in
                    switch response.result {
                    case .success(let movieResponse):
                        continuation.resume(returning: movieResponse.results)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    func getMovieById(_ id: Int) async throws -> MovieAPIResponse {
        let parameters: [String: Any] = [
            "api_key": apiKey
        ]
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request("\(baseURL)/movie/\(id)", parameters: parameters)
                .validate()
                .responseDecodable(of: MovieAPIResponse.self) { response in
                    switch response.result {
                    case .success(let movie):
                        continuation.resume(returning: movie)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}

// MARK: - Demo/Mock Service for when API key is not available
extension MovieService {
    func getMockMovies() -> [MovieAPIResponse] {
        return [
            MovieAPIResponse(
                id: 1,
                title: "The Shawshank Redemption",
                overview: "Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.",
                posterPath: "/9cqNxx0GxF0bflNmkJWsErrQ0I.jpg",
                releaseDate: "1994-09-23",
                voteAverage: 9.3
            ),
            MovieAPIResponse(
                id: 2,
                title: "The Godfather",
                overview: "The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.",
                posterPath: "/3bhkrj58Vtu7enYsRolD1fZdja1.jpg",
                releaseDate: "1972-03-24",
                voteAverage: 9.2
            ),
            MovieAPIResponse(
                id: 3,
                title: "The Dark Knight",
                overview: "When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests.",
                posterPath: "/qJ2tW6WMUDux911r6m7haRef0WH.jpg",
                releaseDate: "2008-07-18",
                voteAverage: 9.0
            ),
            MovieAPIResponse(
                id: 4,
                title: "Pulp Fiction",
                overview: "The lives of two mob hitmen, a boxer, a gangster and his wife, and a pair of diner bandits intertwine in four tales of violence and redemption.",
                posterPath: "/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg",
                releaseDate: "1994-10-14",
                voteAverage: 8.9
            ),
            MovieAPIResponse(
                id: 5,
                title: "Forrest Gump",
                overview: "The presidencies of Kennedy and Johnson, the Vietnam War, the Watergate scandal and other historical events unfold from the perspective of an Alabama man.",
                posterPath: "/arw2vcBveWOVZr6pxd9XTd1TdQa.jpg",
                releaseDate: "1994-07-06",
                voteAverage: 8.8
            )
        ]
    }
}