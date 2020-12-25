// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Duct",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Duct",
            targets: ["Duct"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
//        .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk", from: "7.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Duct",
            dependencies: []),
        .testTarget(
            name: "DuctTests",
            dependencies: ["Duct"]),
    ]
)
