// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SnapPix",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "SnapPix",
            
            targets: ["SnapPix"]),
      
    ],
    targets: [
        .target(
            name: "SnapPix",
            path: "Sources/SnapPix"
        )
    ]

)
