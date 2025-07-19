// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iosmovieappcollection",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "iosmovieappcollection",
            targets: ["iosmovieappcollection"]),
    ],
    dependencies: [
        // Alamofire for advanced networking
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0"),
        // SDWebImage for additional caching features
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "3.1.0"),
        // CodeScanner as barcode scanning alternative
        .package(url: "https://github.com/twostraws/CodeScanner.git", from: "2.5.0")
    ],
    targets: [
        .target(
            name: "iosmovieappcollection",
            dependencies: [
                "Alamofire",
                .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI"),
                "CodeScanner"
            ]
        ),
        .testTarget(
            name: "iosmovieappcollectionTests",
            dependencies: ["iosmovieappcollection"]
        ),
    ]
)