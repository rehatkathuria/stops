import Aesthetics
import ComposableArchitecture
import Foundation
import Shared
import SwiftUI

public struct GalleryUndeterminedView: View {
	let store: StoreOf<GalleryFeature>
	
	public init(store: StoreOf<GalleryFeature>) { self.store = store }
	
	private var gridRows: Array<GridItem> {
		.init(repeating: .init(spacing: 10, alignment: .center), count: 3)
	}
	
	public var body: some View {
		ScrollView(.vertical) {
			LazyVGrid(columns: gridRows) {
				ForEach(0...15, id: \.self) { _ in
					Rectangle()
						.fill(Color.seaSalt.opacity(0.5))
						.aspectRatio(1, contentMode: .fit)
						.redacted(reason: .privacy)
						.cornerRadius(4)
						.shadow(
							color: Color(UIColor.black.withAlphaComponent(0.55)),
							radius: 3,
							x: 0,
							y: 0
						)
						.onTapGesture {
							ViewStore(store.stateless).send(.didRequestGalleryPermissionsOverlayPresentation)
						}
				}
			}
			.padding(.all, 10)
		}
		.extendFrame()
		.background(Color(theme.cardInnerContainerBackgroundColor))
		.mask(
			LinearGradient(
				gradient: Gradient(
					stops: [
						.init(color: .black, location: 0),
						.init(color: .clear, location: 1),
						.init(color: .black, location: 1),
						.init(color: .clear, location: 1)
					]
				),
				startPoint: .top,
				endPoint: .bottom
			)
		)
	}
}
