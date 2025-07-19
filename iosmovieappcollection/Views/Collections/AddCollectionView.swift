//
//  AddCollectionView.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI

struct AddCollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedColor = "#4ECDC4"
    @State private var selectedIcon = "folder.fill"
    
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
            }
            .navigationTitle("Add Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCollection()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveCollection() {
        let collection = Collection(
            name: name,
            collectionDescription: description.isEmpty ? nil : description,
            color: selectedColor,
            iconName: selectedIcon
        )
        
        modelContext.insert(collection)
        dismiss()
    }
}

struct AddCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        AddCollectionView()
    }
}