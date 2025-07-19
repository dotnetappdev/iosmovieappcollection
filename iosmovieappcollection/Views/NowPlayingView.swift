//
//  NowPlayingView.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI
import SwiftData

struct NowPlayingView: View {
    @Query(sort: \Movie.dateAdded, order: .reverse) private var recentMovies: [Movie]
    @Query(filter: #Predicate<Movie> { movie in
        movie.userRating != nil && movie.userRating! >= 8
    }, sort: \Movie.userRating, order: .reverse) private var topRatedMovies: [Movie]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Featured Movie Section
                    if let featuredMovie = recentMovies.first {
                        FeaturedMovieCard(movie: featuredMovie)
                            .padding(.horizontal)
                    }
                    
                    // Recently Added Section
                    if !recentMovies.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recently Added")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                                NavigationLink("See All") {
                                    // Navigate to full recent list
                                }
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Array(recentMovies.prefix(10))) { movie in
                                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                                            MoviePosterCard(movie: movie)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Top Rated Section
                    if !topRatedMovies.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Top Rated")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                                NavigationLink("See All") {
                                    // Navigate to top rated list
                                }
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Array(topRatedMovies.prefix(10))) { movie in
                                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                                            MoviePosterCard(movie: movie)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Quick Stats
                    StatsCardView()
                        .padding(.horizontal)
                    
                    if recentMovies.isEmpty {
                        EmptyNowPlayingView()
                            .padding()
                    }
                }
            }
            .navigationTitle("Now Playing")
        }
    }
}

struct FeaturedMovieCard: View {
    let movie: Movie
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: movie.posterURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .overlay(
                        Image(systemName: "film.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.7))
                    )
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Gradient overlay
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text("FEATURED")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(movie.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                if let year = movie.year {
                    Text(String(year))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
        }
    }
}

struct MoviePosterCard: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            .frame(width: 120, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(movie.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .frame(width: 120, alignment: .leading)
                
                if let year = movie.year {
                    Text(String(year))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct StatsCardView: View {
    @Query private var allMovies: [Movie]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Collection Stats")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                StatItem(
                    title: "Total Movies",
                    value: "\(allMovies.count)",
                    icon: "film.stack.fill"
                )
                
                StatItem(
                    title: "Collected",
                    value: "\(allMovies.filter { !$0.isWanted }.count)",
                    icon: "checkmark.circle.fill"
                )
                
                StatItem(
                    title: "Wanted",
                    value: "\(allMovies.filter { $0.isWanted }.count)",
                    icon: "heart.fill"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct EmptyNowPlayingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "play.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Nothing Playing")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add movies to your collection to see them featured here.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct NowPlayingView_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingView()
            .modelContainer(for: Movie.self, inMemory: true)
    }
}