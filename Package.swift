// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "WorkoutTracker",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "WorkoutTracker",
            targets: ["WorkoutTracker"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.19.0")
    ],
    targets: [
        .target(
            name: "WorkoutTracker",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            ]
        ),
    ]
)
