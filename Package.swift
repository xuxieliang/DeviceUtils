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
            targets: ["DeviceUtils"]
        ),
    ],
    targets: [
        // 主模块 (Swift 部分)
        .target(
            name: "DeviceUtils"
        ),

        // ObjC 部分合并成一个模块
        .target(
            name: "XLComponents", // 新 target 名
            path: "Sources",
            sources: [
                "XLMenuView",
                "XLPageController"
            ],
            publicHeadersPath: ".", // 两个文件夹内的所有 .h 都作为公共头
            cSettings: [
                .headerSearchPath("XLMenuView"),
                .headerSearchPath("XLPageController")
            ]
        )
    ]
)
