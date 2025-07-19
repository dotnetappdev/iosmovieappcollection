# Movie Collection Manager - Setup Guide

## Overview
This iOS Swift app provides a comprehensive movie collection management system with barcode scanning, IMDB integration, and photo library management.

## Required Dependencies

### Swift Package Manager Dependencies
Add these packages through Xcode → File → Add Package Dependencies:

1. **Alamofire** (Optional - for enhanced networking)
   - URL: `https://github.com/Alamofire/Alamofire`
   - Version: Latest
   - Note: The app currently uses URLSession, but Alamofire can be integrated for more advanced networking features

2. **SDWebImage** (Optional - for enhanced image caching)
   - URL: `https://github.com/SDWebImage/SDWebImage`
   - Version: Latest
   - Note: The app includes a custom ImageCacheService, but SDWebImage provides more features

3. **CodeScanner** (Alternative barcode scanner)
   - URL: `https://github.com/twostraws/CodeScanner`
   - Version: Latest
   - Note: Alternative to the custom BarcodeScannerService

### System Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Device with camera (for barcode scanning)

## Setup Instructions

### 1. Xcode Project Configuration

#### Info.plist Setup
The `Info.plist` file is already configured with the necessary privacy descriptions:
- `NSCameraUsageDescription`: For barcode scanning
- `NSPhotoLibraryAddUsageDescription`: For saving movie posters
- `NSAppTransportSecurity`: Configured for OMDB API access

#### Capabilities
No additional capabilities need to be enabled in Xcode.

### 2. IMDB API Configuration

#### Get API Key
1. Visit [OMDB API](http://www.omdbapi.com/apikey.aspx)
2. Sign up for a free API key
3. Note: Free tier allows 1,000 requests per day

#### Configure in App
1. Open the app
2. Go to Settings tab
3. Tap "Configure" next to "IMDB API Key"
4. Enter your API key
5. The base URL is pre-configured as `https://www.omdbapi.com/`

### 3. Permissions Setup

#### Camera Permission
- Required for barcode scanning
- Automatically requested when user tries to scan
- Can be manually requested from Settings → Permissions

#### Photo Library Permission
- Optional but recommended for poster saving
- Automatically requested when user enables photo saving
- Creates two albums: "Movies Collected" and "Movies Wanted"

### 4. Build Configuration

#### Debug vs Release
The app is configured to work in both Debug and Release modes:
- Debug: More verbose logging
- Release: Optimized performance, minimal logging

#### Deployment Target
- Minimum: iOS 17.0
- Recommended: iOS 17.1+

## Features Implementation Status

### ✅ Completed Features
- SwiftData-based movie and collection models
- Complete UI with tab navigation and hamburger menu
- Movie CRUD operations (Create, Read, Update, Delete)
- Collection management with custom colors and icons
- Settings screen with API configuration
- IMDB API integration service
- Barcode scanning service (camera-based)
- Photo library integration
- Image caching service
- Permissions management
- Dark/Light mode support
- Search and filtering
- Now Playing featured movies screen

### 🔄 In Progress Features
- Barcode-to-movie database lookup
- Enhanced error handling
- Offline mode support

### 📋 Future Enhancements
- Movie recommendations
- Social sharing features
- Export/Import functionality
- Advanced statistics
- Backup to iCloud

## Architecture

### MVVM Pattern
The app follows Model-View-ViewModel architecture:
- **Models**: SwiftData entities (Movie, Collection)
- **Views**: SwiftUI views with clear separation of concerns
- **Services**: Business logic and external API integration

### Data Flow
1. **Input**: Barcode scanning or manual entry
2. **Processing**: IMDB API lookup for metadata
3. **Storage**: SwiftData local database
4. **Display**: SwiftUI views with real-time updates
5. **Export**: Photo library integration for poster storage

### Directory Structure
```
iosmovieappcollection/
├── Models/
│   ├── Movie.swift
│   ├── Collection.swift
│   └── AppSettings.swift
├── Views/
│   ├── MainTabView.swift
│   ├── MovieListView.swift
│   ├── Collections/
│   ├── Scanner/
│   └── Settings/
├── Services/
│   ├── IMDBService.swift
│   ├── BarcodeScannerService.swift
│   ├── PhotoLibraryService.swift
│   └── PermissionsService.swift
└── Info.plist
```

## Troubleshooting

### Common Issues

#### API Not Working
- Check API key configuration in Settings
- Verify internet connection
- Ensure API key is valid and not expired

#### Camera Not Working
- Check camera permissions in iOS Settings
- Ensure device has a working camera
- Try restarting the app

#### Photo Library Issues
- Check photo library permissions
- Ensure sufficient storage space
- Verify iOS version compatibility

#### Build Errors
- Clean build folder (Cmd+Shift+K)
- Update to latest Xcode version
- Check iOS deployment target

## Support

### Getting Help
- Check the in-app Help section in Settings
- Review this documentation
- Check iOS system requirements

### Reporting Issues
When reporting issues, include:
- iOS version
- Device model
- App version
- Steps to reproduce
- Error messages (if any)

## Privacy & Security

### Data Protection
- All data stored locally using SwiftData
- No user accounts or cloud sync
- API key stored securely in UserDefaults
- Photo library access only for saving posters
- Camera access only for barcode scanning

### Network Usage
- HTTPS only for API calls
- Minimal data transmission
- No analytics or tracking
- User-configurable API endpoints

## License

This app is built for personal movie collection management. Please respect movie poster copyrights and API terms of service.