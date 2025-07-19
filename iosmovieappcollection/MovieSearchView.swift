//
//  MovieSearchView.swift
//  iosmovieappcollection
//
//  Enhanced movie search using Alamofire and SDWebImage
//

import SwiftUI
import SwiftData
import SDWebImageSwiftUI

struct MovieSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var searchResults: [MovieAPIResponse] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let movieService = MovieService.shared
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearchButtonClicked: performSearch)
                
                if isLoading {
                    ProgressView("Searching movies...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView(
                        "No Movies Found",
                        systemImage: "film",
                        description: Text("Try searching with different keywords")
                    )
                } else if searchResults.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("Search for Movies")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Enter a movie title to search for movies to add to your collection")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Load Popular Movies") {
                            loadPopularMovies()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(searchResults, id: \.id) { movie in
                        MovieSearchRow(movie: movie) {
                            addMovieToCollection(movie)
                        }
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Add Movie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadPopularMovies()
        }
    }
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let results = try await movieService.searchMovies(query: searchText)
                await MainActor.run {
                    searchResults = results
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to search movies. Using mock data instead."
                    searchResults = movieService.getMockMovies().filter { movie in
                        movie.title.localizedCaseInsensitiveContains(searchText)
                    }
                    isLoading = false
                }
            }
        }
    }
    
    private func loadPopularMovies() {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let results = try await movieService.getPopularMovies()
                await MainActor.run {
                    searchResults = results
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to load popular movies. Using mock data instead."
                    searchResults = movieService.getMockMovies()
                    isLoading = false
                }
            }
        }
    }
    
    private func addMovieToCollection(_ movieResponse: MovieAPIResponse) {
        withAnimation {
            let movie = movieResponse.toMovie()
            modelContext.insert(movie)
            dismiss()
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSearchButtonClicked: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search movies...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    onSearchButtonClicked()
                }
            
            Button("Search", action: onSearchButtonClicked)
                .buttonStyle(.borderedProminent)
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }
}

struct MovieSearchRow: View {
    let movie: MovieAPIResponse
    let onAdd: () -> Void
    
    var body: some View {
        HStack {
            WebImage(url: movie.posterPath.flatMap { URL(string: "https://image.tmdb.org/t/p/w200\($0)") })
                .resizable()
                .placeholder {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "film")
                                .foregroundColor(.gray)
                        )
                }
                .indicator(.activity)
                .transition(.fade(duration: 0.5))
                .scaledToFit()
                .frame(width: 60, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(movie.formattedReleaseDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.subheadline)
                }
                
                Text(movie.overview)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
            
            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

extension MovieAPIResponse {
    var formattedReleaseDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: releaseDate) else { return releaseDate }
        
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    MovieSearchView()
        .modelContainer(for: Movie.self, inMemory: true)
}