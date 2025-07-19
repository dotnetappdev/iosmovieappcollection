//
//  iosmovieappcollectionApp.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI
import SwiftData

@main
struct iosmovieappcollectionApp: App {
    @StateObject private var appSettings = AppSettings()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Movie.self,
            Collection.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appSettings)
        }
        .modelContainer(sharedModelContainer)
    }
}
