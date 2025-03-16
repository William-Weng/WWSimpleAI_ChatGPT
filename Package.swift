// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWSimpleAI_ChatGPT",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "WWSimpleAI_ChatGPT", targets: ["WWSimpleAI_ChatGPT"]),
    ],
    dependencies: [
        .package(url: "https://github.com/William-Weng/WWSimpleAI_Ollama", from: "1.0.0")
    ],
    targets: [
        .target(name: "WWSimpleAI_ChatGPT", dependencies: ["WWSimpleAI_Ollama"], resources: [.copy("Privacy")])
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
