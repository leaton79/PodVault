// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PodVault",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PodVault", targets: ["PodVault"])
    ],
    dependencies: [
        // SQLite wrapper with excellent Swift integration
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.24.0"),
        // RSS/Atom feed parsing
        .package(url: "https://github.com/nmdias/FeedKit.git", from: "9.1.2"),
    ],
    targets: [
        .executableTarget(
            name: "PodVault",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "FeedKit", package: "FeedKit"),
            ],
            path: "Sources/PodVault",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PodVaultTests",
            dependencies: ["PodVault"],
            path: "Tests/PodVaultTests"
        )
    ]
)
