// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Leagend",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "Leagend",
            targets: ["Leagend"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/PureSwift/Bluetooth.git",
            .upToNextMajor(from: "6.0.0")
        ),
        .package(
            url: "https://github.com/PureSwift/GATT.git",
            branch: "master"
        )
    ],
    targets: [
        .target(
            name: "Leagend",
            dependencies: [
                .product(
                    name: "Bluetooth",
                    package: "Bluetooth"
                ),
                .product(
                    name: "GATT",
                    package: "GATT"
                ),
            ]
        ),
        .testTarget(
            name: "LeagendTests",
            dependencies: ["Leagend"]
        ),
    ]
)
