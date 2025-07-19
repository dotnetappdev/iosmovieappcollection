//
//  Collection.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import Foundation
import SwiftData

@Model
final class Collection {
    var id: String
    var name: String
    var collectionDescription: String?
    var dateCreated: Date
    var color: String? // Hex color for UI theming
    var iconName: String? // SF Symbol name
    @Relationship var movies: [Movie]?
    
    init(
        id: String = UUID().uuidString,
        name: String,
        collectionDescription: String? = nil,
        dateCreated: Date = Date(),
        color: String? = nil,
        iconName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.collectionDescription = collectionDescription
        self.dateCreated = dateCreated
        self.color = color
        self.iconName = iconName
    }
}

// MARK: - Computed Properties
extension Collection {
    var movieCount: Int {
        movies?.count ?? 0
    }
    
    var displayDescription: String {
        collectionDescription?.isEmpty == false ? collectionDescription! : "No description"
    }
    
    var displayIcon: String {
        iconName?.isEmpty == false ? iconName! : "folder.fill"
    }
}

// MARK: - Predefined Collections
extension Collection {
    static func createDefaultCollections() -> [Collection] {
        return [
            Collection(
                name: "Action",
                collectionDescription: "High-octane action movies",
                color: "#FF6B6B",
                iconName: "bolt.fill"
            ),
            Collection(
                name: "Comedy",
                collectionDescription: "Light-hearted and funny movies",
                color: "#4ECDC4",
                iconName: "face.smiling.fill"
            ),
            Collection(
                name: "Drama",
                collectionDescription: "Serious and emotional storytelling",
                color: "#45B7D1",
                iconName: "theatermasks.fill"
            ),
            Collection(
                name: "Horror",
                collectionDescription: "Scary and thrilling movies",
                color: "#96CEB4",
                iconName: "eye.trianglebadge.exclamationmark.fill"
            ),
            Collection(
                name: "Sci-Fi",
                collectionDescription: "Science fiction and futuristic movies",
                color: "#FFEAA7",
                iconName: "sparkles"
            ),
            Collection(
                name: "Romance",
                collectionDescription: "Love stories and romantic movies",
                color: "#FD79A8",
                iconName: "heart.fill"
            )
        ]
    }
}