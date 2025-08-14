// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DeviceUtils",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "DeviceUtils",
            targets: ["XLPageController"]
        ),
    ],
    targets: [
        // XLMenuView 目标
        .target(
            name: "XLMenuView",
            path: "XLPageController/XLMenuView",
            publicHeadersPath: ".", // 指向包含 .h 的目录
            cSettings: [
                .headerSearchPath(".")
            ]
        ),
        // XLPageController 目标
        .target(
            name: "XLPageController",
            dependencies: ["XLMenuView"],
            path: "XLPageController/Controller",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath(".")
            ]
        )
    ]
)
