import ComposableArchitecture
import SnapshotTesting
import XCTest

@testable import Settings

final class SettingsTests: XCTestCase {
	func testSettingsScreen() {
		let record = false
		let store = Store(initialState: .init(), reducer: SettingsFeature())
		let view = SettingsView(store)
			.growToFitMainScreen()
			.environment(\.colorScheme, .dark)
		
		assertSnapshot(matching: view, as: .image, record: record)
	}
}
