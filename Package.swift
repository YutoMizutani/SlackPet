// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SlackPet",
    platforms: [
        .iOS(.v8), .tvOS(.v9), .macOS(.v10_12), .watchOS(.v2)
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/pvzig/SlackKit.git", .upToNextMajor(from: "4.4.0")),
        .package(url: "https://github.com/YutoMizutani/BitriseAPI-Swift.git", .branch("feature/trigger_build")),
        .package(url: "https://github.com/YutoMizutani/EmojiKit.git", .branch("master"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "BitriseKit",
            dependencies: ["BitriseAPI"],
            path: "Sources/BitriseKit"
        ),
        .target(
            name: "GitHubKit",
            path: "Sources/GitHubKit"
        ),
        .target(
            name: "LongcatKit",
            dependencies: ["ShellKit"],
            path: "Sources/LongcatKit"
        ),
        .target(
            name: "OjichatKit",
            dependencies: ["ShellKit"],
            path: "Sources/OjichatKit"
        ),
        .target(
            name: "ShellKit",
            path: "Sources/ShellKit"
        ),
        .target(
            name: "SlackBot",
            dependencies: ["SlackKit"],
            path: "Sources/SlackBot"
        ),
        .target(
            name: "SlackEmojiKit",
            dependencies: ["EmojiKit", "ShellKit"],
            path: "Sources/SlackEmojiKit"
        ),
        .target(
            name: "SlackPet",
            dependencies: ["BitriseKit", "GitHubKit", "LongcatKit", "OjichatKit", "SlackBot", "SlackEmojiKit"],
            path: "Sources/SlackPet"
        ),
        .testTarget(
            name: "SlackPetTests",
            dependencies: ["SlackPet"],
            path: "Tests/SlackPetTests"
        ),
    ]
)
