//
//  MovieRowView.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI

struct MovieRowView: View {
    let movie: Movie
    
    var body: some View {
        HStack(spacing: 12) {
            // Movie poster
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
                    )
            }
            .frame(width: 60, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Movie details
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                
                if let year = movie.year {
                    Text(String(year))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let genre = movie.genre, !genre.isEmpty {
                    Text(genre)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if let director = movie.director, !director.isEmpty {
                    Text("Dir: \(director)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Bottom row with status and rating
                HStack {
                    // Status indicator
                    if movie.isWanted {
                        Label("Wanted", systemImage: "heart.fill")
                            .font(.caption2)
                            .foregroundColor(.red)
                    } else {
                        Label("Collected", systemImage: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    // User rating
                    if let rating = movie.userRating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(rating)")
                        }
                        .font(.caption2)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct MovieRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            MovieRowView(movie: Movie(
                title: "The Matrix",
                year: 1999,
                director: "The Wachowskis",
                genre: "Action, Sci-Fi",
                userRating: 9
            ))
            
            MovieRowView(movie: Movie(
                title: "Inception",
                year: 2010,
                director: "Christopher Nolan",
                genre: "Action, Thriller",
                isWanted: true,
                userRating: 8
            ))
        }
    }
}