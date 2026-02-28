// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "swift-voice-input",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "VoiceInput", targets: ["VoiceInput"]),
        .library(name: "VoiceInputUI", targets: ["VoiceInputUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/no-problem-dev/swift-design-system.git", .upToNextMajor(from: "1.0.23")),
    ],
    targets: [
        .target(name: "VoiceInput"),
        .target(
            name: "VoiceInputUI",
            dependencies: [
                "VoiceInput",
                .product(name: "DesignSystem", package: "swift-design-system"),
            ]
        ),
        .testTarget(
            name: "VoiceInputTests",
            dependencies: ["VoiceInput"]
        ),
    ]
)
