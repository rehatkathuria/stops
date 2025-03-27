import SwiftUI

fileprivate struct SizeKey: PreferenceKey {
	static var defaultValue: CGSize { .zero }
	
	static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
		value = nextValue()
	}
}

public extension View {
	func onSizeChange(_ onChange: @escaping @MainActor (CGSize) -> ()) -> some View {
		overlay {
			GeometryReader { proxy in
				Color.clear.preference(key: SizeKey.self, value: proxy.size)
			}
			.onPreferenceChange(
				SizeKey.self,
				perform: { key in
					DispatchQueue.main.async {
						onChange(key)
					}
				}
			)
		}
	}
}
