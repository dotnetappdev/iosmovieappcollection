//
//  AppSettings.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import Foundation

class AppSettings: ObservableObject {
    private let userDefaults = UserDefaults.standard
    
    // IMDB API Configuration
    @Published var imdbAPIKey: String {
        didSet {
            userDefaults.set(imdbAPIKey, forKey: "imdbAPIKey")
        }
    }
    
    @Published var imdbAPIBaseURL: String {
        didSet {
            userDefaults.set(imdbAPIBaseURL, forKey: "imdbAPIBaseURL")
        }
    }
    
    // App Configuration
    @Published var autoSaveToPhotos: Bool {
        didSet {
            userDefaults.set(autoSaveToPhotos, forKey: "autoSaveToPhotos")
        }
    }
    
    @Published var defaultMovieRating: Int {
        didSet {
            userDefaults.set(defaultMovieRating, forKey: "defaultMovieRating")
        }
    }
    
    @Published var enableBarcodeSound: Bool {
        didSet {
            userDefaults.set(enableBarcodeSound, forKey: "enableBarcodeSound")
        }
    }
    
    @Published var showMovieCount: Bool {
        didSet {
            userDefaults.set(showMovieCount, forKey: "showMovieCount")
        }
    }
    
    init() {
        // Load saved settings or use defaults
        self.imdbAPIKey = userDefaults.string(forKey: "imdbAPIKey") ?? ""
        self.imdbAPIBaseURL = userDefaults.string(forKey: "imdbAPIBaseURL") ?? "https://www.omdbapi.com/"
        self.autoSaveToPhotos = userDefaults.bool(forKey: "autoSaveToPhotos")
        self.defaultMovieRating = userDefaults.integer(forKey: "defaultMovieRating") == 0 ? 5 : userDefaults.integer(forKey: "defaultMovieRating")
        self.enableBarcodeSound = userDefaults.object(forKey: "enableBarcodeSound") as? Bool ?? true
        self.showMovieCount = userDefaults.object(forKey: "showMovieCount") as? Bool ?? true
    }
    
    // MARK: - Validation
    var isAPIConfigured: Bool {
        !imdbAPIKey.isEmpty && !imdbAPIBaseURL.isEmpty
    }
    
    var hasValidAPIKey: Bool {
        imdbAPIKey.count >= 8 // OMDB API keys are typically longer
    }
    
    // MARK: - Reset Settings
    func resetToDefaults() {
        imdbAPIKey = ""
        imdbAPIBaseURL = "https://www.omdbapi.com/"
        autoSaveToPhotos = false
        defaultMovieRating = 5
        enableBarcodeSound = true
        showMovieCount = true
    }
    
    // MARK: - Export/Import Settings
    func exportSettings() -> [String: Any] {
        return [
            "imdbAPIBaseURL": imdbAPIBaseURL,
            "autoSaveToPhotos": autoSaveToPhotos,
            "defaultMovieRating": defaultMovieRating,
            "enableBarcodeSound": enableBarcodeSound,
            "showMovieCount": showMovieCount
            // Note: Not exporting API key for security
        ]
    }
    
    func importSettings(from data: [String: Any]) {
        if let url = data["imdbAPIBaseURL"] as? String {
            imdbAPIBaseURL = url
        }
        if let autoSave = data["autoSaveToPhotos"] as? Bool {
            autoSaveToPhotos = autoSave
        }
        if let rating = data["defaultMovieRating"] as? Int {
            defaultMovieRating = rating
        }
        if let sound = data["enableBarcodeSound"] as? Bool {
            enableBarcodeSound = sound
        }
        if let showCount = data["showMovieCount"] as? Bool {
            showMovieCount = showCount
        }
    }
}