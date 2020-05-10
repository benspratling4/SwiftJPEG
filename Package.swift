// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftJPEG",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SwiftJPEG",
            targets: ["SwiftJPEG"]),
    ],
    dependencies: [
		.package(url: "https://github.com/benspratling4/SwiftGraphicsCore.git", from: "1.0.5"),
		.package(url: "https://github.com/benspratling4/SwiftPNG.git", from: "1.0.2"),
//		.package(path: "../SwiftPNG"),	//for development when finding bugs in SwiftPNG
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftJPEG",
			dependencies: [.byName(name: "SwiftGraphicsCore")]),
        .testTarget(
            name: "SwiftJPEGTests",
            dependencies: ["SwiftJPEG", "SwiftGraphicsCore", "SwiftPNG"]),
    ]
)
