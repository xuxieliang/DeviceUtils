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
        // Objective-C 部分
        .target(
            name: "XLMenuView",
            path: "Sources/XLMenuView",
            publicHeadersPath: ".", // 让 OC 的头文件可以暴露出去
            cSettings: [
                .headerSearchPath(".")
            ]
        ),
        .target(
            name: "XLPageController",
            dependencies: ["XLMenuView"],
            path: "Sources/XLPageController",
            publicHeadersPath: ".", // 让 OC 的头文件可以暴露出去
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("../XLMenuView") // 手动加上 XLMenuView 的头文件路径
            ]
        )
        
    ]
)
