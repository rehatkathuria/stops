// swift-tools-version: 5.7

import PackageDescription

let package = Package(
	name: "Gallery",
	products: [
		.library(
			name: "Gallery",
			targets: ["Gallery"]
		),
	],
	dependencies: [
	],
	targets: [
		.target(
			name: "Gallery",
			dependencies: []
		),
		.testTarget(
			name: "GalleryTests",
			dependencies: ["Gallery"]
		),
	]
)
