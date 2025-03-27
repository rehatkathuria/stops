// swift-tools-version: 5.10

import PackageDescription

let package = Package(
	name: "CameraFeature",
	defaultLocalization: "en",
	platforms: [
		.iOS("17.2"),
		.macOS(.v12),
	],
	products: [
		.library(name: "CameraFeature", targets: ["CameraFeature"]),
	],
	dependencies: [
		.package(name: "Aesthetics", path: "../Aesthetics"),
		.package(name: "AVCaptureClient", path: "../AVCaptureClient"),
		.package(name: "ExtensionKit", path: "../ExtensionKit"),
		.package(name: "LocationClient", path: "../LocationClient"),
		.package(name: "PermissionsClient", path: "../PermissionsClient"),
		.package(name: "OverlayView", path: "../OverlayView"),
		.package(name: "Preferences", path: "../Preferences"),
		.package(name: "Shared", path: "../Shared"),
		.package(name: "Shoebox", path: "../Shoebox"),
		.package(name: "Shopfront", path: "../Shopfront"),
		.package(name: "Views", path: "../Views"),
	],
	targets: [
		.target(
			name: "CameraFeature",
			dependencies: [
				.product(name: "Aesthetics", package: "Aesthetics"),
				.product(name: "AVCaptureClient", package: "AVCaptureClient"),
				.product(name: "ExtensionKit", package: "ExtensionKit"),
				.product(name: "LocationClient", package: "LocationClient"),
				.product(name: "PermissionsClient", package: "PermissionsClient"),
				.product(name: "OverlayView", package: "OverlayView"),
				.product(name: "Preferences", package: "Preferences"),
				.product(name: "Shared", package: "Shared"),
				.product(name: "Shopfront", package: "Shopfront"),
				.product(name: "Shoebox", package: "Shoebox"),
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
			name: "CameraFeatureTests",
			dependencies: ["CameraFeature"]
		),
	]
)
