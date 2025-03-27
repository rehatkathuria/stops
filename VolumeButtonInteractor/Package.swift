// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "VolumeButtonInteractor",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "VolumeButtonInteractor",
			targets: ["VolumeButtonInteractor"]
		),
	],
	dependencies: [
	],
	targets: [
		.target(
			name: "VolumeButtonInteractor",
			dependencies: [],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-application-extension"])
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-application_extension"])
			]
		),
		.testTarget(
			name: "VolumeButtonInteractorTests",
			dependencies: ["VolumeButtonInteractor"]
		),
	]
)
