//
//  MovieListView.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI
import SwiftData

struct MovieListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var movies: [Movie]
    @State private var searchText = ""
    @State private var showingAddMovie = false
    @State private var sortOrder: SortOrder = .dateAdded
    @State private var filterOption: FilterOption = .all
    
    enum SortOrder: String, CaseIterable {
        case dateAdded = "Date Added"
        case title = "Title"
        case year = "Year"
        case rating = "Rating"
        
        var keyPath: KeyPath<Movie, some Comparable> {
            switch self {
            case .dateAdded:
                return \Movie.dateAdded
            case .title:
                return \Movie.title
            case .year:
                return \Movie.year
            case .rating:
                return \Movie.userRating
            }
        }
    }
    
    enum FilterOption: String, CaseIterable {
        case all = "All Movies"
        case collected = "Collected"
        case wanted = "Wanted"
        case rated = "Rated"
    }
    
    var filteredMovies: [Movie] {
        var filtered = movies
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { movie in
                movie.title.localizedCaseInsensitiveContains(searchText) ||
                (movie.director?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (movie.genre?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (movie.actors?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Apply category filter
        switch filterOption {
        case .all:
            break
        case .collected:
            filtered = filtered.filter { !$0.isWanted }
        case .wanted:
            filtered = filtered.filter { $0.isWanted }
        case .rated:
            filtered = filtered.filter { $0.userRating != nil }
        }
        
        // Apply sorting
        switch sortOrder {
        case .dateAdded:
            filtered = filtered.sorted { $0.dateAdded > $1.dateAdded }
        case .title:
            filtered = filtered.sorted { $0.title < $1.title }
        case .year:
            filtered = filtered.sorted { ($0.year ?? 0) > ($1.year ?? 0) }
        case .rating:
            filtered = filtered.sorted { ($0.userRating ?? 0) > ($1.userRating ?? 0) }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if movies.isEmpty {
                    EmptyMovieListView()
                } else {
                    List {
                        ForEach(filteredMovies) { movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                MovieRowView(movie: movie)
                            }
                        }
                        .onDelete(perform: deleteMovies)
                    }
                    .searchable(text: $searchText, prompt: "Search movies...")
                }
            }
            .navigationTitle("My Movies")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Menu("Sort by") {
                            ForEach(SortOrder.allCases, id: \.self) { order in
                                Button(action: { sortOrder = order }) {
                                    HStack {
                                        Text(order.rawValue)
                                        if sortOrder == order {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                        
                        Menu("Filter") {
                            ForEach(FilterOption.allCases, id: \.self) { option in
                                Button(action: { filterOption = option }) {
                                    HStack {
                                        Text(option.rawValue)
                                        if filterOption == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        Button(action: { showingAddMovie = true }) {
                            Label("Add Movie", systemImage: "plus")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddMovie) {
                AddMovieView()
            }
        }
    }
    
    private func deleteMovies(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredMovies[index])
            }
        }
    }
}

struct EmptyMovieListView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "film.stack")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Movies Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start building your collection by scanning barcodes or adding movies manually.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                // Navigate to scanner or add movie
            }) {
                Label("Get Started", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct MovieListView_Previews: PreviewProvider {
    static var previews: some View {
        MovieListView()
            .modelContainer(for: Movie.self, inMemory: true)
    }
}