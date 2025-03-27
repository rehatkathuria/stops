// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "Shared",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "Shared",
			targets: ["Shared"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.52.0"),
		.package(url: "https://github.com/siteline/SwiftUI-Introspect", branch: "master"),
		
		.package(url: "https://github.com/movingparts-io/Pow", from: "0.3.0"),
	],
	targets: [
		.target(
			name: "Shared",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				.product(name: "Introspect", package: "SwiftUI-Introspect"),
				.product(name: "Pow", package: "Pow"),
			],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-application-extension"])
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-application_extension"])
			]
		),
		.testTarget(
			name: "SharedTests",
			dependencies: [
				"Shared",
			]
		),
	]
)

public let snapshotPackageDependency: Package.Dependency = .package(
	url: "https://github.com/pointfreeco/swift-snapshot-testing",
	branch: "main"
)

public let snapshotTargetDependency = Target.Dependency.product(
	name: "SnapshotTesting",
	package: "swift-snapshot-testing"
)
