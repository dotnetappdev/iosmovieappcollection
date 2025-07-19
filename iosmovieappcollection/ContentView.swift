//
//  ContentView.swift
//  iosmovieappcollection
//
//  Enhanced movie collection app with advanced dependencies
//

import SwiftUI
import SwiftData
import SDWebImageSwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var movies: [Movie]
    
    @State private var isShowingSearchView = false
    @State private var isShowingScannerView = false
    @State private var selectedMovie: Movie?

    var body: some View {
        NavigationSplitView {
            VStack {
                if movies.isEmpty {
                    EmptyMovieCollectionView(
                        onSearchTapped: { isShowingSearchView = true },
                        onScanTapped: { isShowingScannerView = true }
                    )
                } else {
                    List {
                        ForEach(movies) { movie in
                            MovieRowView(movie: movie) {
                                selectedMovie = movie
                            }
                        }
                        .onDelete(perform: deleteMovies)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Menu {
                                Button(action: { isShowingSearchView = true }) {
                                    Label("Search Movies", systemImage: "magnifyingglass")
                                }
                                Button(action: { isShowingScannerView = true }) {
                                    Label("Scan Barcode", systemImage: "barcode.viewfinder")
                                }
                            } label: {
                                Label("Add Movie", systemImage: "plus")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Movie Collection")
        } detail: {
            if let selectedMovie = selectedMovie {
                MovieDetailView(movie: selectedMovie)
            } else {
                ContentUnavailableView(
                    "Select a Movie",
                    systemImage: "film",
                    description: Text("Choose a movie from your collection to see details")
                )
            }
        }
        .sheet(isPresented: $isShowingSearchView) {
            MovieSearchView()
        }
        .sheet(isPresented: $isShowingScannerView) {
            BarcodeScannerView()
        }
    }

    private func deleteMovies(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(movies[index])
            }
        }
    }
}

struct EmptyMovieCollectionView: View {
    let onSearchTapped: () -> Void
    let onScanTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "film")
                .font(.system(size: 64))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("Your Movie Collection")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Start building your movie collection by searching for movies or scanning barcodes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 16) {
                Button(action: onSearchTapped) {
                    Label("Search Movies", systemImage: "magnifyingglass")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button(action: onScanTapped) {
                    Label("Scan Barcode", systemImage: "barcode.viewfinder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MovieRowView: View {
    let movie: Movie
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                WebImage(url: movie.posterURL)
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
                    .frame(width: 50, height: 75)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(movie.title)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(movie.formattedReleaseDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", movie.voteAverage))
                            .font(.caption)
                        
                        if movie.barcode != nil {
                            Spacer()
                            Image(systemName: "barcode")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MovieDetailView: View {
    let movie: Movie
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 20) {
                    WebImage(url: movie.posterURL)
                        .resizable()
                        .placeholder {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "film")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray)
                                )
                        }
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .frame(width: 150, height: 225)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(movie.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Released: \(movie.formattedReleaseDate)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", movie.voteAverage))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("/ 10")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let barcode = movie.barcode {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Barcode")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(barcode)
                                    .font(.monospaced(.caption)())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                        
                        Text("Added: \(movie.dateAdded, format: Date.FormatStyle(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Overview")
                        .font(.headline)
                    
                    Text(movie.overview)
                        .font(.body)
                        .lineSpacing(2)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(movie.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Movie.self, inMemory: true)
}
