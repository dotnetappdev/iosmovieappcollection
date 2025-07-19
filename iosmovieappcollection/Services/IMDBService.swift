//
//  IMDBService.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import Foundation

// MARK: - IMDB API Response Models
struct IMDBResponse: Codable {
    let title: String?
    let year: String?
    let rated: String?
    let released: String?
    let runtime: String?
    let genre: String?
    let director: String?
    let writer: String?
    let actors: String?
    let plot: String?
    let language: String?
    let country: String?
    let awards: String?
    let poster: String?
    let imdbID: String?
    let imdbRating: String?
    let response: String
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case rated = "Rated"
        case released = "Released"
        case runtime = "Runtime"
        case genre = "Genre"
        case director = "Director"
        case writer = "Writer"
        case actors = "Actors"
        case plot = "Plot"
        case language = "Language"
        case country = "Country"
        case awards = "Awards"
        case poster = "Poster"
        case imdbID = "imdbID"
        case imdbRating = "imdbRating"
        case response = "Response"
        case error = "Error"
    }
}

// MARK: - IMDB Service
@MainActor
class IMDBService: ObservableObject {
    private let session = URLSession.shared
    
    enum IMDBError: LocalizedError {
        case invalidURL
        case noAPIKey
        case invalidResponse
        case movieNotFound
        case networkError(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .noAPIKey:
                return "API key not configured"
            case .invalidResponse:
                return "Invalid response from server"
            case .movieNotFound:
                return "Movie not found"
            case .networkError(let message):
                return "Network error: \(message)"
            }
        }
    }
    
    // MARK: - Search by Title
    func searchMovie(title: String, apiKey: String, baseURL: String = "https://www.omdbapi.com/") async throws -> IMDBResponse {
        guard !apiKey.isEmpty else {
            throw IMDBError.noAPIKey
        }
        
        guard var components = URLComponents(string: baseURL) else {
            throw IMDBError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "t", value: title),
            URLQueryItem(name: "plot", value: "full")
        ]
        
        guard let url = components.url else {
            throw IMDBError.invalidURL
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(IMDBResponse.self, from: data)
            
            if response.response == "False" {
                throw IMDBError.movieNotFound
            }
            
            return response
        } catch is DecodingError {
            throw IMDBError.invalidResponse
        } catch {
            throw IMDBError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Search by IMDB ID
    func searchMovieByIMDBID(_ imdbID: String, apiKey: String, baseURL: String = "https://www.omdbapi.com/") async throws -> IMDBResponse {
        guard !apiKey.isEmpty else {
            throw IMDBError.noAPIKey
        }
        
        guard var components = URLComponents(string: baseURL) else {
            throw IMDBError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "i", value: imdbID),
            URLQueryItem(name: "plot", value: "full")
        ]
        
        guard let url = components.url else {
            throw IMDBError.invalidURL
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(IMDBResponse.self, from: data)
            
            if response.response == "False" {
                throw IMDBError.movieNotFound
            }
            
            return response
        } catch is DecodingError {
            throw IMDBError.invalidResponse
        } catch {
            throw IMDBError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Convert IMDB Response to Movie
    func createMovieFromIMDBResponse(_ response: IMDBResponse, isWanted: Bool = false) -> Movie {
        let movie = Movie(
            title: response.title ?? "Unknown Title",
            year: Int(response.year ?? ""),
            director: response.director,
            plot: response.plot,
            genre: response.genre,
            imdbID: response.imdbID,
            posterURL: response.poster != "N/A" ? response.poster : nil,
            isWanted: isWanted,
            runtime: response.runtime,
            actors: response.actors,
            language: response.language,
            country: response.country,
            awards: response.awards != "N/A" ? response.awards : nil
        )
        
        return movie
    }
    
    // MARK: - Download Poster Image
    func downloadPosterImage(from urlString: String?) async -> Data? {
        guard let urlString = urlString,
              urlString != "N/A",
              let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            return data
        } catch {
            print("Failed to download poster: \(error)")
            return nil
        }
    }
    
    // MARK: - Search and Create Movie
    func searchAndCreateMovie(title: String, apiKey: String, baseURL: String, isWanted: Bool = false) async throws -> (Movie, Data?) {
        let response = try await searchMovie(title: title, apiKey: apiKey, baseURL: baseURL)
        let movie = createMovieFromIMDBResponse(response, isWanted: isWanted)
        let posterData = await downloadPosterImage(from: response.poster)
        
        if let posterData = posterData {
            movie.posterImageData = posterData
        }
        
        return (movie, posterData)
    }
}