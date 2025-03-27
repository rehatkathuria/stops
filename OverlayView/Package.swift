// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "OverlayView",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "OverlayView",
			targets: ["OverlayView"]
		),
	],
	dependencies: [
		.package(
			name: "Aesthetics",
			path: "../Aesthetics"
		),
		.package(
			name: "ExtensionKit",
			path: "../ExtensionKit"
		),
		.package(
			name: "Haptics",
			path: "../Haptics"
		),
		.package(
			name: "Shared",
			path: "../Shared"
		),
		.package(
			name: "Views",
			path: "../Views"
		),
	],
	targets: [
		.target(
			name: "OverlayView",
			dependencies: [
				.product(
					name: "Aesthetics",
					package: "Aesthetics"
				),
				.product(
					name: "ExtensionKit",
					package: "ExtensionKit"
				),
				.product(
					name: "Haptics",
					package: "Haptics"
				),
				.product(
					name: "Shared",
					package: "Shared"
				),
				.product(
					name: "Views",
					package: "Views"
				),
			],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-application-extension"])
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-application_extension"])
			]
		),
		.testTarget(
			name: "OverlayViewTests",
			dependencies: ["OverlayView"]
		),
	]
)
