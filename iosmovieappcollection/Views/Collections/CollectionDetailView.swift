//
//  CollectionDetailView.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI

struct CollectionDetailView: View {
    let collection: Collection
    @State private var showingEditSheet = false
    
    var body: some View {
        VStack {
            // Collection header
            VStack(spacing: 16) {
                ZStack {
                    if let colorHex = collection.color {
                        Color(hex: colorHex)
                    } else {
                        Color.accentColor
                    }
                    
                    Image(systemName: collection.displayIcon)
                        .foregroundColor(.white)
                        .font(.system(size: 40))
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                
                VStack(spacing: 4) {
                    Text(collection.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(collection.displayDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("\(collection.movieCount) movies")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            // Movies in collection
            if collection.movieCount == 0 {
                EmptyCollectionView(collectionName: collection.name)
            } else {
                List {
                    ForEach(collection.movies ?? []) { movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            MovieRowView(movie: movie)
                        }
                    }
                }
            }
        }
        .navigationTitle(collection.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditCollectionView(collection: collection)
        }
    }
}

struct EmptyCollectionView: View {
    let collectionName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Movies")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Movies assigned to the \(collectionName) collection will appear here.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
}

struct CollectionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CollectionDetailView(collection: Collection(
                name: "Action",
                collectionDescription: "High-octane action movies",
                color: "#FF6B6B"
            ))
        }
    }
}