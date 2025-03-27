import SwiftUI

public extension View {
	func overlay<S: ShapeStyle>(
		isShown: Bool,
		_ style: S,
		ignoresSafeAreaEdges edges: Edge.Set = .all
	) -> some View {
		return overlay {
			if isShown {
				Color.clear.edgesIgnoringSafeArea(edges).overlay(style)
			}
		}
	}
	
	func overlay<Content: View>(
		isShown: Bool,
		alignment: Alignment = .center,
		@ViewBuilder _ content: @escaping () -> Content
	) -> some View {
		overlay(alignment: alignment) {
			if isShown {
				content()
			}
		}
	}
	
	func overlay<Item, Content: View>(
		item: Item?,
		alignment: Alignment = .center,
		@ViewBuilder _ content: @escaping (Item) -> Content
	) -> some View {
		overlay(alignment: alignment) {
			item.map(content)
		}
	}
}
