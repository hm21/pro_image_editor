// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "pro_image_editor",
  platforms: [
    .iOS(.v12),
    .macOS(.v11),
  ],
  products: [
    .library(name: "pro-image-editor", targets: ["pro_image_editor"])
  ],
  dependencies: [
    .package(path: "../FlutterFramework")
  ],
  targets: [
    .target(
      name: "pro_image_editor",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework")
      ],
      path: ".",
      resources: [],
      linkerSettings: [
        .linkedFramework("Flutter", .when(platforms: [.iOS])),
        .linkedFramework("FlutterMacOS", .when(platforms: [.macOS])),
      ]
    )
  ]
)
