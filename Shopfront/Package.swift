// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "Shopfront",
	defaultLocalization: "en",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "Shopfront",
			targets: ["Shopfront"]
		),
	],
	dependencies: [
		.package(path: "../Aesthetics"),
		.package(path: "../OverlayView"),
		.package(path: "../Shared"),
		.package(path: "../Views"),
		
		.package(url: "https://github.com/efremidze/Shiny", branch: "master")
	],
	targets: [
		.target(
			name: "Shopfront",
			dependencies: [
				.product(name: "Aesthetics", package: "Aesthetics"),
				.product(name: "OverlayView", package: "OverlayView"),
				.product(name: "Shared", package: "Shared"),
				.product(name: "Views", package: "Views"),

				.product(name: "Shiny", package: "Shiny"),
			],
			resources: [
				.process("Resources")
			],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-application-extension"])
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-application_extension"])
			]
		),
		.testTarget(
			name: "ShopfrontTests",
			dependencies: ["Shopfront"]
		),
	]
)
