// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XcresultParser",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "XcresultParser",
            targets: ["XcresultParser"]
        ),
        .executable(
            name: "xcresult-cli",
            targets: ["XcresultCLI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/davidahouse/XCResultKit.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "XcresultParser",
            dependencies: [
                "XCResultKit"
            ]
        ),
        .executableTarget(
            name: "XcresultCLI",
            dependencies: [
                "XcresultParser",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "XcresultParserTests",
            dependencies: ["XcresultParser"]
        )
    ]
)
