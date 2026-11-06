// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RC-X-ray",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "RCXrayCore", targets: ["RCXrayCore"]),
        .executable(name: "RC-X-ray", targets: ["RC-X-ray"])
    ],
    targets: [
        .target(name: "RCXrayCore"),
        .executableTarget(name: "RC-X-ray", dependencies: ["RCXrayCore"]),
        .testTarget(name: "RCXrayCoreTests", dependencies: ["RCXrayCore"])
    ]
)
