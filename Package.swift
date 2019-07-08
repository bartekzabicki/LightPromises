// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LightPromises",
    products: [
        .library(
            name: "LightPromises",
            targets: ["LightPromises"]),
    ],
    targets: [
        .target(
            name: "LightPromises"),
    ]
)
