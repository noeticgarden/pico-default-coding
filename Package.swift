// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "pico-default-coding",
    products: [
        .library(
            name: "DefaultCoding",
            targets: ["DefaultCoding"]
        ),
    ],
    targets: [
        .target(
            name: "DefaultCoding",
            path: "."
        ),
    ]
)
