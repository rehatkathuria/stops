// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "AVCaptureClient",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(name: "AVCaptureClient", targets: ["AVCaptureClient"]),
	],
	dependencies: [
		.package(name: "OrientationClient", path: "../OrientationClient"),
		.package(name: "Shared", path: "../Shared"),
		.package(name: "Shopfront", path: "../Shopfront"),
		.package(name: "Pipeline", path: "../Pipeline"),
		.package(name: "Preferences", path: "../Preferences"),
	],
	targets: [
		.target(
			name: "AVCaptureClient",
			dependencies: [
				.product(name: "OrientationClient", package: "OrientationClient"),
				.product(name: "Shared", package: "Shared"),
				.product(name: "Shopfront", package: "Shopfront"),
				.product(name: "Preferences", package: "Preferences"),
				.product(name: "Pipeline", package: "Pipeline"),
			],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-application-extension"])
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-application_extension"])
			]
		),
		.testTarget(
			name: "AVCaptureClientTests",
			dependencies: ["AVCaptureClient"]
		),
	]
)
