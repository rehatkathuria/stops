// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "ExtensionKit",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "ExtensionKit",
			targets: ["ExtensionKit"]
		)
	],
	dependencies: [
		.package(name: "Shared", path: "../Shared"),
	],
	targets: [
		.target(
			name: "ExtensionKit",
			dependencies: [
				.product(name: "Shared", package: "Shared"),
			],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-application-extension"])
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-application_extension"])
			]
		),
		.testTarget(
			name: "ExtensionKitTests",
			dependencies: ["ExtensionKit"]
		)
	]
)
