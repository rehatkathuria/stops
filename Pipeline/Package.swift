// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "Pipeline",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "Pipeline",
			targets: ["Pipeline"]
		),
	],
	dependencies: [
		/// Pipeline Target
		.package(name: "Core", path: "../Core"),
		.package(name: "Shared", path: "../Shared"),
		

	],
	targets: [
		.target(
			name: "Pipeline",
			dependencies: [
				.product(name: "Core", package: "Core"),
				.product(name: "Shared", package: "Shared"),
			],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-application-extension"])
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-application_extension"])
			]
		),
		.testTarget(
			name: "PipelineTests",
			dependencies: [
				"Pipeline",
				"Shared",
			],
			resources: [
				.process("Resources")
			]
		),
	]
)
