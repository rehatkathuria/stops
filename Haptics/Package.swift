// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "Haptics",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "Haptics",
			targets: ["Haptics"]
		),
	],
	dependencies: [
		.package(
			name: "Shared",
			path: "../Shared"
		),
	],
	targets: [
		.target(
			name: "Haptics",
			dependencies: [
				.product(
					name: "Shared",
					package: "Shared"
				)
			],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-application-extension"])
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-application_extension"])
			]
		),
		.testTarget(
			name: "HapticsTests",
			dependencies: ["Haptics"]
		),
	]
)
