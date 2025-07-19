# iOS Movie App Collection

An enhanced iOS movie collection app built with SwiftUI and SwiftData, featuring advanced networking, image caching, and barcode scanning capabilities.

## Features

### Core Functionality
- **Movie Collection Management**: Add, view, and delete movies from your personal collection
- **Movie Search**: Search for movies using an integrated search interface
- **Barcode Scanning**: Scan movie barcodes to add them to your collection
- **Movie Details**: View detailed information about each movie including posters, ratings, and descriptions

### Enhanced Dependencies

This app has been enhanced with three powerful dependencies as requested:

#### 1. Alamofire for Advanced Networking
- **Purpose**: Advanced HTTP networking capabilities
- **Usage**: Handles API requests to movie databases (TMDB API)
- **Features**:
  - Asynchronous movie search
  - Popular movies fetching
  - Robust error handling
  - Request validation

#### 2. SDWebImage for Image Caching
- **Purpose**: Efficient image loading and caching
- **Usage**: Loads and caches movie poster images
- **Features**:
  - Automatic image caching
  - Progressive image loading
  - Placeholder support
  - Memory optimization

#### 3. CodeScanner for Barcode Scanning
- **Purpose**: Barcode and QR code scanning functionality
- **Usage**: Scan movie barcodes to add movies to collection
- **Features**:
  - Multiple barcode format support (UPC-A, UPC-E, EAN-8, EAN-13, Code 128, QR)
  - Camera integration
  - Real-time scanning

## Project Structure

```
iosmovieappcollection/
├── Package.swift                     # Swift Package Manager dependencies
├── iosmovieappcollection/
│   ├── iosmovieappcollectionApp.swift # Main app entry point
│   ├── ContentView.swift             # Main collection view
│   ├── Movie.swift                   # Movie data model
│   ├── MovieService.swift            # Networking service using Alamofire
│   ├── MovieSearchView.swift         # Movie search interface
│   ├── BarcodeScannerView.swift      # Barcode scanning interface
│   └── Assets.xcassets/             # App assets
├── iosmovieappcollectionTests/       # Unit tests
└── iosmovieappcollectionUITests/     # UI tests
```

## Dependencies

### Swift Package Manager
The app uses Swift Package Manager to manage the following dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0"),
    .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "3.1.0"),
    .package(url: "https://github.com/twostraws/CodeScanner.git", from: "2.5.0")
]
```

## Setup Instructions

### Prerequisites
- iOS 18.0+
- Xcode 15.0+
- Swift 6.0+

### Installation
1. Clone the repository
2. Open `iosmovieappcollection.xcodeproj` in Xcode
3. The Swift Package Manager dependencies will be automatically resolved
4. Build and run the project

### API Configuration
To use real movie data:
1. Get a free API key from [The Movie Database (TMDB)](https://www.themoviedb.org/settings/api)
2. Replace `"your_tmdb_api_key_here"` in `MovieService.swift` with your actual API key

## Usage

### Adding Movies
1. **Search**: Tap the "+" button and select "Search Movies" to search for movies by title
2. **Scan**: Tap the "+" button and select "Scan Barcode" to scan movie barcodes

### Viewing Collection
- Browse your movie collection in the main list view
- Tap on any movie to view detailed information
- Use swipe gestures to delete movies from your collection

### Movie Details
Each movie shows:
- Poster image (cached with SDWebImage)
- Title and release date
- IMDb rating
- Plot overview
- Barcode information (if scanned)
- Date added to collection

## Technical Highlights

### Data Persistence
- Uses SwiftData for modern Core Data integration
- Automatic data persistence across app launches
- Efficient querying and updates

### Networking
- Alamofire integration for robust HTTP networking
- Async/await pattern for modern concurrency
- Comprehensive error handling
- Mock data fallback for offline usage

### Image Management
- SDWebImage for efficient poster image loading
- Automatic caching to reduce network usage
- Progressive loading with placeholders
- Memory-conscious image handling

### Barcode Scanning
- CodeScanner integration for camera access
- Multiple barcode format support
- User-friendly scanning interface
- Manual entry fallback

## Architecture

The app follows modern iOS development patterns:
- **SwiftUI**: Declarative user interface
- **SwiftData**: Modern data persistence
- **MVVM**: Separation of concerns
- **Async/Await**: Modern concurrency
- **Swift Package Manager**: Dependency management

## Contributing

This project demonstrates the integration of popular iOS libraries for networking, image caching, and barcode scanning. Feel free to contribute improvements or report issues.

## License

This project is available under the MIT license.