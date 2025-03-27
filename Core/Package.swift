// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "Core",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "Core",
			targets: ["Core"]
		),
	],
	dependencies: [
		.package(name: "Shared", path: "../Shared"),
	],
	targets: [
		.target(
			name: "Core",
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
			name: "CoreTests",
			dependencies: ["Core"]
		),
	]
)
