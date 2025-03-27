import Aesthetics
import ComposableArchitecture
import Foundation
import SwiftUI
import Views

public struct GalleryView: View {
	
	let store: StoreOf<GalleryFeature>
	@Environment(\.shutterStyle) var shutterStyle
	
	public init(store: StoreOf<GalleryFeature>) { self.store = store }
	
	public var body: some View {
		WithViewStore(store) { viewStore in
			Group {
				AssetViewRepresentable(store: store, shutterStyle: shutterStyle)
			}
			.overlay(isShown: viewStore.permissionsNotGranted, {
				GalleryUndeterminedView(store: store)
			})
			.sheet(
				item: viewStore.binding(
					get: \.assetImageToShare,
					send: GalleryFeature.Action.setAssetShareSheetImage
				)
			) { image in
				ShareSheet(activityItems: [image]) { completed in
					viewStore.send(.setShouldPresentShareSheet(false))
				}
				.presentationDetents([.medium])
				.edgesIgnoringSafeArea(.all)
			}
			.onAppear { viewStore.send(.didAppear) }
		}
	}
}

extension UIImage: Identifiable { }
