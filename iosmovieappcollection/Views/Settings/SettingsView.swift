//
//  SettingsView.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var showingAPIKeyAlert = false
    @State private var tempAPIKey = ""
    
    var body: some View {
        NavigationView {
            Form {
                // API Configuration Section
                Section("API Configuration") {
                    HStack {
                        Label("IMDB API Key", systemImage: "key.fill")
                        Spacer()
                        if appSettings.hasValidAPIKey {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.orange)
                        }
                        Button("Configure") {
                            tempAPIKey = appSettings.imdbAPIKey
                            showingAPIKeyAlert = true
                        }
                        .foregroundColor(.accentColor)
                    }
                    
                    HStack {
                        Label("API Endpoint", systemImage: "network")
                        Spacer()
                        Text(appSettings.imdbAPIBaseURL.isEmpty ? "Not Set" : "Configured")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                // App Preferences Section
                Section("Preferences") {
                    Toggle(isOn: $appSettings.autoSaveToPhotos) {
                        Label("Auto-save Posters", systemImage: "photo.on.rectangle.angled")
                    }
                    
                    Toggle(isOn: $appSettings.enableBarcodeSound) {
                        Label("Barcode Scan Sound", systemImage: "speaker.wave.2.fill")
                    }
                    
                    Toggle(isOn: $appSettings.showMovieCount) {
                        Label("Show Movie Count", systemImage: "number.circle.fill")
                    }
                    
                    HStack {
                        Label("Default Rating", systemImage: "star.fill")
                        Spacer()
                        Picker("Default Rating", selection: $appSettings.defaultMovieRating) {
                            ForEach(1...10, id: \.self) { rating in
                                Text("\(rating)")
                                    .tag(rating)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // Storage Section
                Section("Storage") {
                    NavigationLink(destination: StorageManagementView()) {
                        Label("Manage Storage", systemImage: "internaldrive.fill")
                    }
                    
                    NavigationLink(destination: DataExportView()) {
                        Label("Export Data", systemImage: "square.and.arrow.up.fill")
                    }
                }
                
                // About Section
                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle.fill")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        Label("About App", systemImage: "questionmark.circle.fill")
                    }
                    
                    Button(action: {
                        // Open privacy policy
                    }) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                }
                
                // Reset Section
                Section("Reset") {
                    Button(action: {
                        appSettings.resetToDefaults()
                    }) {
                        Label("Reset Settings", systemImage: "arrow.clockwise.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .alert("Configure API Key", isPresented: $showingAPIKeyAlert) {
            TextField("IMDB API Key", text: $tempAPIKey)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                appSettings.imdbAPIKey = tempAPIKey
            }
        } message: {
            Text("Enter your IMDB API key to enable movie metadata fetching. You can get a free API key from www.omdbapi.com")
        }
    }
}

struct StorageManagementView: View {
    var body: some View {
        List {
            Section("Cache") {
                HStack {
                    Label("Image Cache", systemImage: "photo.stack.fill")
                    Spacer()
                    Text("25.3 MB")
                        .foregroundColor(.secondary)
                    Button("Clear") {
                        // Clear image cache
                    }
                    .foregroundColor(.red)
                }
                
                HStack {
                    Label("Database Size", systemImage: "externaldrive.fill")
                    Spacer()
                    Text("12.1 MB")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Photo Albums") {
                NavigationLink(destination: PhotoAlbumSettingsView()) {
                    Label("Manage Albums", systemImage: "rectangle.stack.fill")
                }
            }
        }
        .navigationTitle("Storage")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DataExportView: View {
    var body: some View {
        List {
            Section("Export Options") {
                Button(action: {
                    // Export as JSON
                }) {
                    Label("Export as JSON", systemImage: "doc.text.fill")
                }
                
                Button(action: {
                    // Export as CSV
                }) {
                    Label("Export as CSV", systemImage: "tablecells.fill")
                }
                
                Button(action: {
                    // Share collection
                }) {
                    Label("Share Collection", systemImage: "square.and.arrow.up.fill")
                }
            }
            
            Section("Import") {
                Button(action: {
                    // Import from file
                }) {
                    Label("Import Collection", systemImage: "square.and.arrow.down.fill")
                }
            }
        }
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PhotoAlbumSettingsView: View {
    var body: some View {
        List {
            Section("Photo Library Albums") {
                HStack {
                    Label("Movies Collected", systemImage: "checkmark.circle.fill")
                    Spacer()
                    Text("Auto-created")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                HStack {
                    Label("Movies Wanted", systemImage: "heart.fill")
                    Spacer()
                    Text("Auto-created")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            Section("Actions") {
                Button(action: {
                    // Create albums
                }) {
                    Label("Create Albums", systemImage: "plus.circle.fill")
                }
                
                Button(action: {
                    // Sync posters
                }) {
                    Label("Sync All Posters", systemImage: "arrow.clockwise.circle.fill")
                }
            }
        }
        .navigationTitle("Photo Albums")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(spacing: 16) {
                    Image(systemName: "film.stack.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("Movie Collection Manager")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("About")
                        .font(.headline)
                    
                    Text("A personal movie collection app for iOS, built in Swift using SwiftData, with support for barcode scanning, IMDB lookup, image storage, and genre-based organization.")
                        .font(.body)
                    
                    Text("Features")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureRow(icon: "barcode.viewfinder", text: "Barcode scanning for UK DVDs")
                        FeatureRow(icon: "network", text: "IMDB integration for metadata")
                        FeatureRow(icon: "photo.fill", text: "Automatic poster storage")
                        FeatureRow(icon: "folder.fill", text: "Custom collections and genres")
                        FeatureRow(icon: "magnifyingglass", text: "Fast local search")
                        FeatureRow(icon: "moon.fill", text: "Dark and Light mode support")
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            Text(text)
                .font(.body)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppSettings())
    }
}