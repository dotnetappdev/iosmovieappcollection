//
//  MovieDetailView.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with poster and basic info
                HStack(alignment: .top, spacing: 16) {
                    AsyncImage(url: URL(string: movie.posterURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "film.fill")
                                    .foregroundColor(.gray)
                                    .font(.title)
                            )
                    }
                    .frame(width: 150, height: 225)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(movie.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let year = movie.year {
                            Text(String(year))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let genre = movie.genre {
                            Text(genre)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        
                        if let rating = movie.userRating {
                            HStack {
                                ForEach(1...10, id: \.self) { star in
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                }
                            }
                        }
                        
                        // Status badge
                        HStack {
                            Image(systemName: movie.isWanted ? "heart.fill" : "checkmark.circle.fill")
                            Text(movie.isWanted ? "Wanted" : "Collected")
                        }
                        .font(.caption)
                        .foregroundColor(movie.isWanted ? .red : .green)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                // Movie details
                VStack(alignment: .leading, spacing: 16) {
                    if let plot = movie.plot, !plot.isEmpty {
                        DetailSection(title: "Plot", content: plot)
                    }
                    
                    if let director = movie.director, !director.isEmpty {
                        DetailSection(title: "Director", content: director)
                    }
                    
                    if let actors = movie.actors, !actors.isEmpty {
                        DetailSection(title: "Actors", content: actors)
                    }
                    
                    if let runtime = movie.runtime, !runtime.isEmpty {
                        DetailSection(title: "Runtime", content: runtime)
                    }
                    
                    if let language = movie.language, !language.isEmpty {
                        DetailSection(title: "Language", content: language)
                    }
                    
                    if let country = movie.country, !country.isEmpty {
                        DetailSection(title: "Country", content: country)
                    }
                    
                    if let awards = movie.awards, !awards.isEmpty {
                        DetailSection(title: "Awards", content: awards)
                    }
                    
                    if let imdbID = movie.imdbID, !imdbID.isEmpty {
                        DetailSection(title: "IMDB ID", content: imdbID)
                    }
                    
                    if let barcode = movie.barcode, !barcode.isEmpty {
                        DetailSection(title: "Barcode", content: barcode)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(movie.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditMovieView(movie: movie)
        }
    }
}

struct DetailSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(content)
                .font(.body)
        }
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MovieDetailView(movie: Movie(
                title: "The Matrix",
                year: 1999,
                director: "The Wachowskis",
                plot: "A computer programmer is led to fight an underground war against powerful computers who have constructed his entire reality with a system called the Matrix.",
                genre: "Action, Sci-Fi",
                userRating: 9,
                runtime: "136 min",
                actors: "Keanu Reeves, Laurence Fishburne, Carrie-Anne Moss",
                language: "English",
                country: "USA"
            ))
        }
    }
}