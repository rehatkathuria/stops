// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "Shoebox",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "Shoebox",
			targets: ["Shoebox"]
		),
	],
	dependencies: [
		.package(name: "Shared", path: "../Shared"),
	],
	targets: [
		.target(
			name: "Shoebox",
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
			name: "ShoeboxTests",
			dependencies: ["Shoebox"]
		),
	]
)
