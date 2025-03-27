import Aesthetics
import ComposableArchitecture
import Foundation
import SwiftUI
import Views

public struct SettingsIconSelectionView: View {
	
	private var columns: Array<GridItem> {
		.init(repeating: .init(spacing: 10, alignment: .center), count: 4)
	}
	
	private let alternativeLightIcons: Array<AppIcon> = AppIcon.lightIcons
	private let alternativeDarkIcons: Array<AppIcon> = AppIcon.darkIcons
	
	private let store: StoreOf<SettingsFeature>
	private let scheme: ColorScheme
	
	public init(
		store: StoreOf<SettingsFeature>,
		scheme: ColorScheme
	) {
		self.store = store
		self.scheme = scheme
	}
	
	public var body: some View {
		WithViewStore(store, observe: \.alternativeAppIconName) { appIconNameStore in
			LazyVGrid(columns: columns) {
				ForEach(
					scheme == .light ? alternativeLightIcons : alternativeDarkIcons
				) { icon in
					Image(uiImage: icon.preview)
						.resizable()
						.aspectRatio(1, contentMode: .fill)
						.cornerRadius(17)
						.overlay(isShown: appIconNameStore.state == icon.iconName, alignment: .topTrailing) {
							SealCheckmark()
								.offset(x: 8.5, y: -8.5)
						}
						.onTapGesture {
							appIconNameStore.send(.didRequestSetAppIcon(icon))
						}
				}
			}
		}
	}
}
