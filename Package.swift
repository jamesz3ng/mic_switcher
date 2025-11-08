// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MicSwitcher",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(
            name: "mic-switcher",
            targets: ["MicSwitcher"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MicSwitcher",
            dependencies: [],
            path: "Sources"
        )
    ]
)
