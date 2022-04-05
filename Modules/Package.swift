// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [
      .iOS(.v15)
    ],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "RecipesFeature", targets: ["RecipesFeature"]),
        .library(name: "RecipeFeature", targets: ["RecipeFeature"]),
        .library(name: "AddRecipeFeature", targets: ["AddRecipeFeature"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "Views", targets: ["Views"]),
        .library(name: "ImageClient", targets: ["ImageClient"]),
        .library(name: "ImageClientLive", targets: ["ImageClientLive"]),
        .library(name: "RecipeClient", targets: ["RecipeClient"]),
        .library(name: "RecipeClientLive", targets: ["RecipeClientLive"]),
        .library(name: "Assets", targets: ["Assets"]),
        .library(name: "Mocks", targets: ["Mocks"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.34.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "8.14.0")
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                "RecipesFeature",
                "Models",
                "Views",
                "RecipeClientLive",
                "ImageClientLive",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "RecipesFeature",
            dependencies: [
                "RecipeFeature",
                "AddRecipeFeature",
                "Models",
                "Views",
                "RecipeClient",
                "ImageClient",
                "Assets",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "RecipeFeature",
            dependencies: [
                "Models",
                "Views",
                "RecipeClient",
                "ImageClient",
                "Assets",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "AddRecipeFeature",
            dependencies: [
                "Models",
                "Views",
                "ImageClient",
                "RecipeClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Models",
            dependencies: ["Mocks"]
        ),
        .target(name: "Mocks"),
        .target(
            name: "Views",
            dependencies: ["Assets"]
        ),
        .target(
            name: "Assets",
            resources: [.process("Resources")]
        ),
        .target(
            name: "RecipeClient",
            dependencies: [
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "RecipeClientLive",
            dependencies: [
                "RecipeClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FirebaseDatabase", package: "firebase-ios-sdk")
            ]
        ),
        .target(
            name: "ImageClient",
            dependencies: [
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "ImageClientLive",
            dependencies: [
                "ImageClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorageSwift-Beta", package: "firebase-ios-sdk")
            ]
        ),
        .testTarget(
            name: "AddRecipeFeatureTests",
            dependencies: [
                "AddRecipeFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "RecipeFeatureTests",
            dependencies: [
                "RecipeFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "RecipesFeatureTests",
            dependencies: [
                "RecipesFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        )
    ]
)
