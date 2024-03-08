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
        ),
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            .upToNextMajor(from: "1.8.1")
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
                .product(
                    name: "CryptoSwift",
                    package: "CryptoSwift"
                )
            ]
        ),
        .testTarget(
            name: "LeagendTests",
            dependencies: [
                "Leagend",
                .product(
                    name: "BluetoothGAP",
                    package: "Bluetooth",
                    condition: .when(platforms: [.macOS, .linux])
                )
            ]
        ),
    ]
)
