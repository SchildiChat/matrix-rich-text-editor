// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// NOTE: Any updates to this file that also need to be mirrored on matrix-rich-text-editor-swift (unless they're related to testing).

let package = Package(
    name: "WysiwygComposer",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "WysiwygComposer",
            targets: ["WysiwygComposer"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.18.4"
        ),
        .package(
            url: "https://github.com/Cocoanetics/DTCoreText",
            exact: "1.6.26"
        ),
    ],
    targets: [
        .target(
            name: "DTCoreTextExtended",
            dependencies: [
                .product(name: "DTCoreText", package: "DTCoreText"),
            ]
        ),
        .target(
            name: "HTMLParser",
            dependencies: [
                .product(name: "DTCoreText", package: "DTCoreText"),
                .target(name: "DTCoreTextExtended"),
            ]
        ),
        .binaryTarget(
            name: "WysiwygComposerFFI",
            path: "WysiwygComposerFFI.xcframework"
        ),
        .target(
            name: "WysiwygComposer",
            dependencies: [
                .target(name: "WysiwygComposerFFI"),
                .target(name: "HTMLParser"),
            ]
        ),
        .testTarget(
            name: "HTMLParserTests",
            dependencies: [
                "HTMLParser",
            ]
        ),
        .testTarget(
            name: "WysiwygComposerTests",
            dependencies: [
                "WysiwygComposer",
            ]
        ),
        .testTarget(
            name: "WysiwygComposerSnapshotTests",
            dependencies: [
                "WysiwygComposer",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)
