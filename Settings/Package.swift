// swift-tools-version: 5.8

import PackageDescription

public let snapshotPackageDependency: Package.Dependency = .package(
	url: "https://github.com/pointfreeco/swift-snapshot-testing",
	branch: "main"
)

public let snapshotTargetDependency = Target.Dependency.product(
	name: "SnapshotTesting",
	package: "swift-snapshot-testing"
)

let package = Package(
	name: "Settings",
	defaultLocalization: "en",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "Settings",
			targets: ["Settings"]
		)
	],
	dependencies: [
		.package(name: "Aesthetics", path: "../Aesthetics"),
		.package(name: "AVCaptureClient", path: "../AVCaptureClient"),
		.package(name: "ExtensionKit", path: "../ExtensionKit"),
		.package(name: "Haptics", path: "../Haptics"),
		.package(name: "LocationClient", path: "../LocationClient"),
		.package(name: "OverlayView", path: "../OverlayView"),
		.package(name: "Preferences", path: "../Preferences"),
		.package(name: "Shared", path: "../Shared"),
		.package(name: "Shopfront", path: "../Shopfront"),
		.package(name: "Views", path: "../Views"),
		
		snapshotPackageDependency,
	],
	targets: [
		.target(
			name: "Settings",
			dependencies: [
				.product(name: "Aesthetics", package: "Aesthetics"),
				.product(name: "AVCaptureClient", package: "AVCaptureClient"),
				.product(name: "ExtensionKit", package: "ExtensionKit"),
				.product(name: "Haptics", package: "Haptics"),
				.product(name: "LocationClient", package: "LocationClient"),
				.product(name: "OverlayView", package: "OverlayView"),
				.product(name: "Preferences", package: "Preferences"),
				.product(name: "Shared", package: "Shared"),
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
			name: "SettingsTests",
			dependencies: [
				"Settings",
				snapshotTargetDependency,
			]
		),
	]
)
