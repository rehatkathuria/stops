import Aesthetics
import CameraFeature
import ComposableArchitecture
import GalleryFeature
import Introspect
import Settings
import Shared
import Shopfront
import SwiftUI
import Views

public struct AppView: View {
	
	// MARK: - Substructures
	
	public struct ViewModel: Equatable {
		let isHorizontalSwipeEnabled: Bool
		let isPresentingSheet: Bool
		let screen: Screen
		let shutterStyle: ShutterStyle
	}
	
	// MARK: - Properties
	
	private let store: StoreOf<AppFeature>
	
	@Environment(\.isPresentingSheet) var isPresentingSheet
	@Environment(\.locale) var locale
	
	static var controlsOffset: CGFloat = 175
	
	// MARK: - Helpers
	
	private var camera: some View {
		CameraView(
			store.scope(
				state: \.camera,
				action: AppFeature.Action.camera
			)
		)
	}
	
	private var cameraTabAccessories: some View {
		WithViewStore(
			store.scope(
				state: \.camera,
				action: AppFeature.Action.camera
			)
		) { viewStore in
			WithViewStore(store, observe: \.screen) { screenState in
				if viewStore.shouldShowCameraButton {
					ChunkyButton(
						.primary,
						.swiftImage(Asset.Phosphor.dotsSix.swiftUIImage),
						minWidth: 150,
						longPressDownAction: { },
						longPressUpAction: { }
					) {
						viewStore.send(.didPressShutter(.photo))
					}
					.grayscale(viewStore.isCurrentQuantizationRestricted ? 1 : 0)
					.opacity(
						screenState.state == .camera
							? 1.0
							: 0.85
					)
					.scaleEffect(
						x: screenState.state == .camera ? 1.0 : 1.5,
						y: screenState.state == .camera ? 1.0 : 0.0,
						anchor: .center
					)
					.animation(
						screenState.state == .camera
							? .spring(response: 0.25, dampingFraction: 0.5)
							: .spring(response: 0.25, dampingFraction: 1.0),
						value: screenState.state
					)
				}
			}
		}
	}
	
	private var shoebox: some View {
		GalleryView(
			store: store.scope(
				state: \.gallery, action:
					AppFeature.Action.gallery
			)
		)
	}
	
	// MARK: -

	private var paginatedBody: some View {
		HorizontalSwipableViewRepresentable(store: store, frame: UIScreen.main.bounds)
	}
	
	private var navigation: some View {
		WithViewStore(store) { appViewStore in
			HStack {
				ZStack {
					let offset = CGFloat(100)
					HStack(spacing: 0) {
						Text("S")
							.offset(y: appViewStore.hasAppeared == true ? 0 : offset)
							.animation(.springable, value: appViewStore.hasAppeared)
							.foregroundColor(appViewStore.shouldColourNavigationTitle == false ? .seaSalt : .seaBlue)
							.animation(.easeOut, value: appViewStore.shouldColourNavigationTitle)
						
						Text("t")
							.offset(y: appViewStore.hasAppeared ? 0 : offset)
							.animation(.springable.delay(0.05), value: appViewStore.hasAppeared)
							.foregroundColor(appViewStore.shouldColourNavigationTitle == false ? .seaSalt : .bubblegum)
							.animation(.easeOut.delay(0.05), value: appViewStore.shouldColourNavigationTitle)
						
						Text("o")
							.offset(y: appViewStore.hasAppeared ? 0 : offset)
							.animation(.springable.delay(0.10), value: appViewStore.hasAppeared)
							.foregroundColor(appViewStore.shouldColourNavigationTitle == false ? .seaSalt : .simpsons)
							.animation(.easeOut.delay(0.15), value: appViewStore.shouldColourNavigationTitle)
						
						Text("p")
							.offset(y: appViewStore.hasAppeared ? 0 : offset)
							.animation(.springable.delay(0.15), value: appViewStore.hasAppeared)
							.foregroundColor(appViewStore.shouldColourNavigationTitle == false ? .seaSalt : .armyGreen)
							.animation(.easeOut.delay(0.20), value: appViewStore.shouldColourNavigationTitle)
						
						Text("s")
							.offset(y: appViewStore.hasAppeared ? 0 : offset)
							.animation(.springable.delay(0.20), value: appViewStore.hasAppeared)
							.foregroundColor(appViewStore.shouldColourNavigationTitle == false ? .seaSalt : .punchyRed)
							.animation(.easeOut.delay(0.30), value: appViewStore.shouldColourNavigationTitle)
					}
				}
				.boldThemedFont(size: 30)
				
				Spacer()
				
				WithViewStore(
					store.scope(
						state: \.camera,
						action: AppFeature.Action.camera
					)
				) { cameraViewStore in
					ZStack(alignment: .trailing) {
						/// Navigation Buttons
						HStack {
							Spacer()
							
							ZStack {
								SquareButton(
									image: .image(Asset.PhosphorBold.apertureBold.swiftUIImage),
									backgroundColor: .white,
									foregroundColor: .gray,
									iconOffset: 0,
									iconSize: 35,
									imageScale: .large
								) {
									NotificationCenter.default.post(name: didRequestNavigationToCameraNotification, object: nil)
								}
								.animation(.springable.delay(0.15), value: appViewStore.screen)
								.offset(y: appViewStore.screen == .shoebox ? 0.0 : 100)
								
								if cameraViewStore.cameraPermission == .allowed {
									SquareButton(
										image: .image(Asset.PhosphorBold.mountainsBold.swiftUIImage),
										backgroundColor: .white,
										foregroundColor: .gray,
										iconOffset: 0,
										iconSize: 35,
										imageScale: .large
									) {
										NotificationCenter.default.post(name: didRequestNavigationToGalleryNotification, object: nil)
									}
									.animation(.springable.delay(0.025), value: appViewStore.screen)
									.offset(y: appViewStore.screen == .camera ? 0.0 : 100)
								}
							}
							.offset(y: appViewStore.gallery.isPresentingDetailedImageView ? 100.0 : 0.0)
							.animation(.springable.delay(0.10), value: appViewStore.gallery.isPresentingDetailedImageView)
							.allowsHitTesting(appViewStore.gallery.hasFinishedPresenting)
							
							if cameraViewStore.cameraPermission == .allowed {
								SquareButton(
									image: .image(Asset.PhosphorFill.gearSixFill.swiftUIImage),
									backgroundColor: .gray,
									foregroundColor: .white,
									iconOffset: 0,
									iconSize: 35,
									imageScale: .large
								) {
									appViewStore.send(
										.setIsSettingsViewVisible(true)
									)
								}
								.offset(y: appViewStore.gallery.isPresentingDetailedImageView ? 100.0 : 0.0)
								.animation(.springable.delay(0.05), value: appViewStore.gallery.isPresentingDetailedImageView)
								.allowsHitTesting(appViewStore.gallery.hasFinishedPresenting)
							}
						}
					}
				}
			}
			.onAppear { appViewStore.send(.begin) }
		}
		.padding()
	}
	
	private var bottomControls: some View {
		WithViewStore(store, observe: \.screen) { screenStore in
			ZStack {
				CameraControlsView(
					store,
					store.scope(
						state: \.camera,
						action: AppFeature.Action.camera
					)
				)
				
				ShoeboxControlsView(
					store,
					store.scope(
						state: \.camera,
						action: AppFeature.Action.camera
					)
				)
			}
		}
	}
	
	@ViewBuilder
	private func tabbedContent() -> some View {
		TabbedViewControllerRepresentable(
			navigationView: {
				AnyView(navigation.environment(\.layoutDirection, .leftToRight))
			},
			bodyView: { AnyView(paginatedBody) },
			tabView: { AnyView(bottomControls) },
			tabAccessoriesView: { AnyView(cameraTabAccessories) }
		)
	}
	
	// MARK: - View
	
	public var body: some View {
		WithViewStore(
			store,
			observe: { state in
				ViewModel(
					isHorizontalSwipeEnabled: state.isHorizontalSwipeEnabled,
					isPresentingSheet: state.isPresentingSheet,
					screen: state.screen,
					shutterStyle: state.camera.shutterStyle
				)
			}
		) { (value) in
			ZStack {
				Color.clear
					.overlay {
						WithViewStore(store) { viewStore in
							Color.clear
								.sheet(
									isPresented: viewStore.binding(
										get: \.isSettingsViewVisible,
										send: AppFeature.Action.setIsSettingsViewVisible
									)
								) {
									IfLetStore(
										store.scope(
											state: returningLastNonNilValue(\.settings),
											action: AppFeature.Action.settings
										)
									) { scopedStore in
										SettingsView(scopedStore)
									}
								}
								.sheet(
									isPresented: viewStore.binding(
										get: \.isShopfrontViewVisible,
										send: AppFeature.Action.setIsShopfrontVisible
									)
								) {
									IfLetStore(
										store.scope(
											state: returningLastNonNilValue(\.shopfront),
											action: AppFeature.Action.shopfront
										)
									) { scopedStore in
										UpgradeToProView(store: scopedStore)
											.interactiveDismissDisabled(viewStore.shopfront?.attemptingToCheckout == true)
									}
								}
						}
					}
				
				tabbedContent()
				
				AppOverlays(store)
			}
			.environment(\.isPresentingSheet, value.isPresentingSheet)
			.environment(\.shutterStyle, value.shutterStyle)
		}
	}

	// MARK: - Lifecycle
	
	public init(_ store: StoreOf<AppFeature>) { self.store = store }
	
}

struct AppView_Preview: PreviewProvider {
	static var previews: some View {
		let store = Store(
			initialState: AppFeature.State(),
			reducer: AppFeature()
		)
		
		AppView(store)
			.preferredColorScheme(.dark)
			.previewLayout(.sizeThatFits)
			.registerCustomFonts()
	}
}
