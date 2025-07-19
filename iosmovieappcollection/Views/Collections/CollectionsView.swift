//
//  CollectionsView.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI
import SwiftData

struct CollectionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var collections: [Collection]
    @State private var showingAddCollection = false
    
    var body: some View {
        NavigationView {
            VStack {
                if collections.isEmpty {
                    EmptyCollectionsView()
                } else {
                    List {
                        ForEach(collections) { collection in
                            NavigationLink(destination: CollectionDetailView(collection: collection)) {
                                CollectionRowView(collection: collection)
                            }
                        }
                        .onDelete(perform: deleteCollections)
                    }
                }
            }
            .navigationTitle("Collections")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCollection = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCollection) {
                AddCollectionView()
            }
            .onAppear {
                createDefaultCollectionsIfNeeded()
            }
        }
    }
    
    private func deleteCollections(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(collections[index])
            }
        }
    }
    
    private func createDefaultCollectionsIfNeeded() {
        if collections.isEmpty {
            let defaultCollections = Collection.createDefaultCollections()
            for collection in defaultCollections {
                modelContext.insert(collection)
            }
        }
    }
}

struct CollectionRowView: View {
    let collection: Collection
    
    var body: some View {
        HStack(spacing: 12) {
            // Collection icon
            ZStack {
                if let colorHex = collection.color {
                    Color(hex: colorHex)
                } else {
                    Color.accentColor
                }
                
                Image(systemName: collection.displayIcon)
                    .foregroundColor(.white)
                    .font(.title2)
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Collection details
            VStack(alignment: .leading, spacing: 4) {
                Text(collection.name)
                    .font(.headline)
                
                Text(collection.displayDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text("\(collection.movieCount) movies")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct EmptyCollectionsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.fill.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Collections")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create collections to organize your movies by genre, director, or any custom category.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                // Create default collections
            }) {
                Label("Create Collections", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// Color extension to support hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct CollectionsView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsView()
            .modelContainer(for: Collection.self, inMemory: true)
    }
}