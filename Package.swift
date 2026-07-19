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
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.0"),
        .package(url: "https://github.com/no-problem-dev/swift-design-system.git", from: "2.0.1"),
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
