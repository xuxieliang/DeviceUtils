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
        // Swift 部分
        .target(
            name: "DeviceUtils",
            dependencies: ["XLPageController"]
        ),
        // Objective-C 部分
        .target(
            name: "XLPageController",
            publicHeadersPath: "." // 让 OC 的头文件可以暴露出去
        )
    ]
)
