// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PawsInUs",
    platforms: [
        .iOS(.v18),
        .macOS(.v12)
    ],
    products: [
        .library(name: "PawsInUs", targets: ["PawsInUs"])
    ],
    dependencies: [
        .package(url: "https://github.com/nalexn/ViewInspector", from: "0.10.0"),
        .package(url: "https://github.com/supabase-community/supabase-swift", from: "2.0.0"),
        .package(url: "https://github.com/nalexn/EnvironmentOverrides", from: "0.0.4")
    ],
    targets: [
        .target(
            name: "PawsInUs",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "EnvironmentOverrides", package: "EnvironmentOverrides")
            ],
            path: "PawsInUs",
            exclude: [
                "Resources/Preview Assets.xcassets",
            ],
            resources: [
                .process("Resources/Assets.xcassets"),
                .process("Resources/Localizable.xcstrings"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ],
            linkerSettings: [
                .linkedFramework("UIKit")
            ]
        ),
        .testTarget(
            name: "UnitTests",
            dependencies: [
                "PawsInUs",
                .product(name: "ViewInspector", package: "ViewInspector")
            ],
            path: "UnitTests",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ],
        )
    ]
)
