// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "OrientationClient",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "OrientationClient",
			targets: ["OrientationClient"]
		),
	],
	dependencies: [
	],
	targets: [
		.target(
			name: "OrientationClient",
			dependencies: [],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-application-extension"])
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-application_extension"])
			]
		),
		.testTarget(
			name: "OrientationClientTests",
			dependencies: ["OrientationClient"]
		),
	]
)
