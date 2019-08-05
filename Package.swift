// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SlackPet",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pvzig/SlackKit.git", .upToNextMajor(from: "4.4.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "GitHubKit",
            dependencies: [],
            path: "Sources/GitHubKit"
        ),
        .target(
            name: "SlackBot",
            dependencies: ["SlackKit"],
            path: "Sources/SlackBot"
        ),
        .target(
            name: "SlackPet",
            dependencies: ["GitHubKit", "SlackBot"],
            path: "Sources/SlackPet"
        ),
        .testTarget(
            name: "SlackPetTests",
            dependencies: ["SlackPet"],
            path: "Tests/SlackPetTests"
        ),
    ]
)
