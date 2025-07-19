//
//  EditCollectionView.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI

struct EditCollectionView: View {
    let collection: Collection
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var description: String
    @State private var selectedColor: String
    @State private var selectedIcon: String
    
    private let availableColors = [
        "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4",
        "#FFEAA7", "#FD79A8", "#FDCB6E", "#6C5CE7",
        "#A29BFE", "#FD79A8", "#E17055", "#00B894"
    ]
    
    private let availableIcons = [
        "folder.fill", "star.fill", "heart.fill", "flame.fill",
        "bolt.fill", "crown.fill", "diamond.fill", "theatermasks.fill",
        "film.fill", "tv.fill", "gamecontroller.fill", "books.vertical.fill"
    ]
    
    init(collection: Collection) {
        self.collection = collection
        _name = State(initialValue: collection.name)
        _description = State(initialValue: collection.collectionDescription ?? "")
        _selectedColor = State(initialValue: collection.color ?? "#4ECDC4")
        _selectedIcon = State(initialValue: collection.iconName ?? "folder.fill")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Collection Name", text: $name)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Appearance") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(availableColors, id: \.self) { color in
                                Button(action: { selectedColor = color }) {
                                    Circle()
                                        .fill(Color(hex: color))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                        )
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icon")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button(action: { selectedIcon = icon }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedIcon == icon ? Color.accentColor : Color.gray.opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: icon)
                                            .foregroundColor(selectedIcon == icon ? .white : .primary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Preview") {
                    HStack {
                        ZStack {
                            Color(hex: selectedColor)
                            Image(systemName: selectedIcon)
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading) {
                            Text(name.isEmpty ? "Collection Name" : name)
                                .font(.headline)
                                .foregroundColor(name.isEmpty ? .secondary : .primary)
                            
                            Text(description.isEmpty ? "Collection description" : description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Information") {
                    HStack {
                        Text("Movies in Collection")
                        Spacer()
                        Text("\(collection.movieCount)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Date Created")
                        Spacer()
                        Text(collection.dateCreated, format: .dateTime.day().month().year())
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        collection.name = name
        collection.collectionDescription = description.isEmpty ? nil : description
        collection.color = selectedColor
        collection.iconName = selectedIcon
        
        dismiss()
    }
}

struct EditCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        EditCollectionView(collection: Collection(
            name: "Action",
            collectionDescription: "High-octane action movies",
            color: "#FF6B6B",
            iconName: "bolt.fill"
        ))
    }
}