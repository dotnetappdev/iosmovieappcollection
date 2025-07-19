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
    @StateObject private var permissionsService = PermissionsService()
    @State private var showingPermissions = false
    
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
            if showingPermissions {
                PermissionsView {
                    showingPermissions = false
                }
                .environmentObject(appSettings)
                .environmentObject(permissionsService)
            } else {
                MainTabView()
                    .environmentObject(appSettings)
                    .environmentObject(permissionsService)
                    .onAppear {
                        checkPermissions()
                    }
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func checkPermissions() {
        permissionsService.updatePermissionStatuses()
        
        // Show permissions screen on first launch or if camera permission is denied
        let hasShownPermissions = UserDefaults.standard.bool(forKey: "hasShownPermissions")
        
        if !hasShownPermissions || permissionsService.cameraPermissionStatus == .denied {
            showingPermissions = true
            UserDefaults.standard.set(true, forKey: "hasShownPermissions")
        }
    }
}
