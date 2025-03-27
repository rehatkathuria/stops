// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "Convenience",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "Convenience",
			targets: ["Convenience"]
		),
	],
	dependencies: [],
	targets: [
		.target(
			name: "Convenience",
			dependencies: [],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-application-extension"])
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-application_extension"])
			]
		),
		.testTarget(
			name: "ConvenienceTests",
			dependencies: ["Convenience"]
		),
	]
)
