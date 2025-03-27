// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "GalleryFeature",
	defaultLocalization: "en",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "GalleryFeature",
			targets: ["GalleryFeature"]
		),
	],
	dependencies: [
		.package(name: "Aesthetics", path: "../Aesthetics"),
		.package(name: "Convenience", path: "../Convenience"),
		.package(name: "Haptics", path: "../Haptics"),
		.package(name: "OverlayView", path: "../OverlayView"),
		.package(name: "PermissionsClient", path: "../PermissionsClient"),
		.package(name: "Preferences", path: "../Preferences"),
		.package(name: "Shared", path: "../Shared"),
		.package(name: "Shoebox", path: "../Shoebox"),
		.package(name: "Shopfront", path: "../Shopfront"),
		.package(name: "Views", path: "../Views"),
	],
	targets: [
		.target(
			name: "GalleryFeature",
			dependencies: [
				.product(name: "Aesthetics", package: "Aesthetics"),
				.product(name: "Convenience", package: "Convenience"),
				.product(name: "Haptics", package: "Haptics"),
				.product(name: "OverlayView", package: "OverlayView"),
				.product(name: "PermissionsClient", package: "PermissionsClient"),
				.product(name: "Preferences", package: "Preferences"),
				.product(name: "Shared", package: "Shared"),
				.product(name: "Shoebox", package: "Shoebox"),
				.product(name: "Shopfront", package: "Shopfront"),
				.product(name: "Views", package: "Views"),
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
			name: "GalleryFeatureTests",
			dependencies: ["GalleryFeature"]
		),
	]
)
