import Aesthetics
import ComposableArchitecture
import ExtensionKit
import Foundation
import OverlayView
import Shared
import Shopfront
import SwiftUI
import Views

public struct SettingsView: View {
	
	// MARK: - Properties
	
	private let store: StoreOf<SettingsFeature>
	private let sectionElementsSpacing = CGFloat(10)
	private let titleToSubtitleSpacing = CGFloat(0)
	private let titleFontSize = CGFloat(16)
	private let subtitleFontSize = CGFloat(12)
	private let iconSize = CGFloat(35)
	private let iconScale = Image.Scale.medium
	private let iconOffset = CGFloat(0)
	private let horizontalIconToExplanationSpacing = CGFloat(10)
	private let cornerRadius = CGFloat(8)
	private let theme = Theme()
	
	@ObservedObject private var shopfrontClient = ShopfrontClient.shared
	
	@Environment(\.lacksPhysicalHomeButton) var lacksPhysicalHomeButton
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	
	@State var isPresentingPrivacyPolicy = false
	
	// MARK: - View
	
	@ViewBuilder
	private func targetOutline(_ shutterStyle: ShutterStyle) -> some View {
		let fullSize = CGSize(width: 100, height: 150)
		
		VStack {
			ZStack {
				RoundedRectangle(cornerRadius: cornerRadius + 2, style: .continuous)
					.fill(Color.black)
					.frame(width: fullSize.width, height: fullSize.height)
				
				RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
					.fill(Color(theme.cardBorderStripColor))
					.frame(width: fullSize.width - 3, height: fullSize.height - 3)
				
				RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
					.fill(Color(theme.cardInnerContainerBackgroundColor))
					.frame(width: fullSize.width - 5, height: fullSize.height - 5)
					.overlay(isShown: shutterStyle == .viewfinder, alignment: .top) {
						Rectangle()
							.fill(Color.gray)
							.offset(x: 0.5)
							.frame(width: fullSize.width - 28, height: fullSize.width)
							.shadow(
								color: Color(UIColor.black.withAlphaComponent(0.55)),
								radius: 2,
								x: 0,
								y: 0
							)
					}
			}
			.overlay {
				VStack {
					Spacer()
					
					VStack(spacing: 0) {
						Rectangle()
							.fill(Color(theme.cardBorderStripColor))
							.frame(width: fullSize.width - 3, height: 1)
						
						Rectangle()
							.fill(Color.black)
							.frame(height: 1.75)
					}
						.padding(.bottom, 35)
						.overlay(isShown: shutterStyle == .dedicatedButton, alignment: .top) {
							HStack {
								Rectangle()
									.fill(Color.gray)
									.cornerRadius(4)
									.frame(width: 40, height: 15)
									.padding(.top, -6)
									.shadow(
										color: Color(UIColor.black.withAlphaComponent(0.55)),
										radius: 2,
										x: 0,
										y: 1
									)
							}
						}
				}
			}
		}
	}
	
	private var cameraControls: some View {
		WithViewStore(store) { viewStore in
			VStack(alignment: .leading, spacing: sectionElementsSpacing) {
				VStack(spacing: titleToSubtitleSpacing) {
					HStack(spacing: 0) {
						Text(L10n.startingCamera)
						
						Text(viewStore.defaultCameraPosition == .front ? L10n.front : L10n.back)
							.foregroundColor(.orange)
						
						Spacer()
					}
					.mediumThemedFont(size: titleFontSize)
					
					HStack {
						Text(L10n.selectTheCameraYouWouldLikeTheAppToStartWithWhenLaunchingFromScratch)
							.themedFont(size: subtitleFontSize)
							.foregroundColor(.secondary)
						
						Spacer()
					}
				}
				.onTapGesture {
					viewStore.send(.setToggleDefaultCameraPosition)
				}
				
				HStack(alignment: .top, spacing: horizontalIconToExplanationSpacing) {
					VStack(spacing: titleToSubtitleSpacing) {
						HStack(spacing: 0) {
							Text(L10n.reverseCameraControls)
							
							Spacer()
						}
						.mediumThemedFont(size: titleFontSize)
						
						HStack {
							Text(L10n.reverseTheIconOrderToBeTheOppositeDirectionOfYourLanguage)
								.themedFont(size: subtitleFontSize)
								.foregroundColor(.secondary)
							
							Spacer()
						}
					}
					
					Spacer()
					
					WithViewStore(store) { viewStore in
						Toggle(
							isOn: viewStore.binding(
								get: \.shouldReverseCameraControls,
								send: SettingsFeature.Action.setShouldReverseCameraControls
							)
						) { }
							.fixedSize()
							.extendFrame(.vertical)
					}
				}
				.padding(.top, 5)
			}
			.sectionStyling
		}
	}
	
	private var metadataControls: some View {
		WithViewStore(store) { viewStore in
			VStack {
				HStack(alignment: .top, spacing: horizontalIconToExplanationSpacing) {
					VStack(spacing: titleToSubtitleSpacing) {
						HStack {
							Text(L10n.album)
								.mediumThemedFont(size: titleFontSize)
							
							Spacer()
						}
						
						HStack {
							Text(L10n.whenSavingPhotosAddThemToAnAlbumNamedStops)
								.themedFont(size: subtitleFontSize)
								.foregroundColor(.secondary)
							
							Spacer()
						}
					}
					
					Spacer()
					
					WithViewStore(store) { viewStore in
						Toggle(
							isOn: viewStore.binding(
								get: \.shouldAddCapturesToApplicationPhotoAlbum,
								send: SettingsFeature.Action.setShouldAddCapturesToApplicationPhotoAlbum
							)
						) { }
							.fixedSize()
							.extendFrame(.vertical)
					}
				}
				
				HStack(alignment: .top, spacing: horizontalIconToExplanationSpacing) {
					VStack(spacing: titleToSubtitleSpacing) {
						HStack(spacing: 0) {
							Text(L10n.location)
							
							Spacer()
						}
						.mediumThemedFont(size: titleFontSize)
						
						HStack {
							Text(L10n.attachLocationMetadataToCapturedImages)
								.themedFont(size: subtitleFontSize)
								.foregroundColor(.secondary)
							
							Spacer()
						}
					}
					
					Spacer()
					
					WithViewStore(store) { viewStore in
						Toggle(
							isOn: viewStore.binding(
								get: \.shouldEmbedLocationDataInCaptures,
								send: SettingsFeature.Action.setShouldEmbedLocationDataInCaptures
							)
						) { }
							.fixedSize()
							.extendFrame(.vertical)
					}
				}
			}
		}
		.sectionStyling
	}
	
	private var shutterControls: some View {
		VStack(alignment: .leading, spacing: sectionElementsSpacing) {
			VStack(spacing: titleToSubtitleSpacing) {
				HStack {
					Text(L10n.shutter)
					
					Spacer()
				}
				.mediumThemedFont(size: titleFontSize)
				
				HStack {
					Text(L10n.youCanChooseBetweenUsingTheViewfinderAsAShutterOrHavingADedicatedButton)
						.themedFont(size: subtitleFontSize)
						.foregroundColor(.secondary)
					
					Spacer()
				}
				
				WithViewStore(store, observe: \.shutterStyle) { viewStore in
					SymmetricHStack {
						EmptyView()
					} leading: {
						VStack {
							ZStack {
								targetOutline(.dedicatedButton)
									.overlay(isShown: viewStore.state == .dedicatedButton, alignment: .topTrailing) {
										SealCheckmark()
											.offset(x: 7, y: -7)
											.blendMode(.saturation)
									}
							}
							
							Text(L10n.dedicatedButton)
								.foregroundColor(viewStore.state == .dedicatedButton ? .orange : .secondary)
								.boldThemedFont(size: 15)
						}
						.onTapGesture {
							viewStore.send(.setShutterStyle(.dedicatedButton))
						}
						
					} trailing: {
						VStack {
							ZStack {
								targetOutline(.viewfinder)
									.overlay(isShown: viewStore.state == .viewfinder, alignment: .topTrailing) {
										SealCheckmark()
											.offset(x: 7, y: -7)
											.blendMode(.saturation)
									}
							}
							
							Text(L10n.viewfinder)
								.foregroundColor(viewStore.state == .viewfinder ? .orange : .secondary)
								.boldThemedFont(size: 15)
						}
						.onTapGesture {
							viewStore.send(.setShutterStyle(.viewfinder))
						}
						.padding(.trailing)
					}
					.padding(.horizontal)
					.padding(.top)
				}
			}
		}
		.sectionStyling
	}
	
	private var generalControls: some View {
		WithViewStore(store) { viewStore in
			VStack {
				HStack(alignment: .top, spacing: horizontalIconToExplanationSpacing) {
					VStack(spacing: titleToSubtitleSpacing) {
						HStack {
							Text(L10n.haptics)
								.mediumThemedFont(size: titleFontSize)
							
							Spacer()
						}
						
						HStack {
							Text(L10n.enableSubtleVibrationsOnButtonTapsAndAnimations)
								.themedFont(size: subtitleFontSize)
								.foregroundColor(.secondary)
							
							Spacer()
						}
					}
					
					Spacer()
					
					WithViewStore(store) { viewStore in
						Toggle(
							isOn: viewStore.binding(
								get: \.shouldEnableHaptics,
								send: SettingsFeature.Action.setShouldEnableHaptics
							)
						) { }
							.fixedSize()
							.extendFrame(.vertical)
					}
				}
			}
		}
		.sectionStyling
	}
	
	private var appStoreControls: some View {
		VStack(spacing: sectionElementsSpacing) {
			HStack(alignment: .top, spacing: horizontalIconToExplanationSpacing) {
				VStack(alignment: .leading, spacing: titleToSubtitleSpacing + 4) {
					Text(L10n.stopsPro)
						.mediumThemedFont(size: titleFontSize)
					
					Text(L10n.stopsProExplainer)
						.themedFont(size: subtitleFontSize)
						.foregroundColor(.secondary)
				}
				
				Spacer()
				
				SquareButton(
					image: .image(Asset.PhosphorFill.lightningFill.swiftUIImage),
					backgroundColor: .orange,
					foregroundColor: .black,
					iconOffset: 0,
					imageScale: .large
				) { ViewStore(store.stateless).send(.didRequestStopsProManagement) }
					.extendFrame(.vertical)
			}
			.onTapGesture { ViewStore(store.stateless).send(.didRequestStopsProManagement) }
			
			HStack(alignment: .top, spacing: horizontalIconToExplanationSpacing) {
				VStack(alignment: .leading, spacing: titleToSubtitleSpacing + 4) {
					Text(L10n.rateApp)
						.mediumThemedFont(size: titleFontSize)
					
					Text(L10n.gotFiveSecondsAndStarsToSpareWeDReallyAppreciateAReview)
						.themedFont(size: subtitleFontSize)
						.foregroundColor(.secondary)
				}
				
				Spacer()
				
				SquareButton(
					image: .image(Asset.Phosphor.pencilCircle.swiftUIImage),
					backgroundColor: .bubblegum,
					foregroundColor: .black,
					iconOffset: 0,
					imageScale: .extraLarge
				) { ViewStore(store.stateless).send(.didRequestToRateApp) }
					.extendFrame(.vertical)
			}
			.onTapGesture { ViewStore(store.stateless).send(.didRequestToRateApp) }
			
			if !shopfrontClient.hasActiveSubscription {
				HStack(alignment: .top, spacing: horizontalIconToExplanationSpacing) {
					VStack(alignment: .leading, spacing: titleToSubtitleSpacing + 4) {
						Text(L10n.restorePurchases)
							.mediumThemedFont(size: titleFontSize)
						
						Text(L10n.fetchAndRestoreAPreviouslyPurchasedSubscriptionFromTheAppStore)
							.themedFont(size: subtitleFontSize)
							.foregroundColor(.secondary)
					}
					
					Spacer()
					
					SquareButton(
						image: .image(Asset.Phosphor.appStoreLogo.swiftUIImage),
						backgroundColor: .blue,
						foregroundColor: .white,
						iconOffset: 0
					) { ViewStore(store.stateless).send(.didRequestAppStoreSync) }
						.extendFrame(.vertical)
				}
				.onTapGesture { ViewStore(store.stateless).send(.didRequestAppStoreSync) }
			}
		}
		.sectionStyling
	}
	
	private func appIcons(scheme: ColorScheme) -> some View {
		VStack(spacing: sectionElementsSpacing) {
			SettingsIconSelectionView(store: store, scheme: scheme)
		}
		.if(scheme == .light, { view in
			view.sectionStyling
		})
		.if(scheme == .dark, { view in
			view.darkContentSectionStyling
		})
	}
	
	private var socials: some View {
		WithViewStore(store) { viewStore in
			VStack(spacing: sectionElementsSpacing) {
				HStack(alignment: .top, spacing: horizontalIconToExplanationSpacing) {
					VStack(alignment: .leading, spacing: titleToSubtitleSpacing + 4) {
						Text("Instagram")
							.mediumThemedFont(size: titleFontSize)
						
						Text(L10n.comeSayHelloWePromiseWeDonTPostReels)
							.themedFont(size: subtitleFontSize)
							.foregroundColor(.secondary)
					}
					
					Spacer()
					
					SquareButton(
						image: .image(Asset.Phosphor.heartStraight.swiftUIImage),
						backgroundColor: .watermelon,
						foregroundColor: .white,
						iconOffset: 0
					) { viewStore.send(.setWantsInstagramNavigation) }
						.extendFrame(.vertical)
				}
				.onTapGesture {
					viewStore.send(.setWantsInstagramNavigation)
				}
				
//				HStack(alignment: .top, spacing: horizontalIconToExplanationSpacing) {
//					VStack(alignment: .leading, spacing: titleToSubtitleSpacing + 4) {
//						Text("Telegram")
//							.mediumThemedFont(size: titleFontSize)
//						
//						Text(L10n.previewsOfUpcomingFeaturesAndOtherUpdates)
//							.themedFont(size: subtitleFontSize)
//							.foregroundColor(.secondary)
//					}
//					
//					Spacer()
//					
//					SquareButton(
//						image: .image(Asset.Phosphor.chatCircleText.swiftUIImage),
//						backgroundColor: .banana,
//						foregroundColor: .black,
//						iconOffset: 0
//					) { viewStore.send(.setWantsTelegramNavigation) }
//						.extendFrame(.vertical)
//				}
//				.onTapGesture { viewStore.send(.setWantsTelegramNavigation) }
			}
			.sectionStyling
		}
	}
	
	private var legal: some View {
		WithViewStore(store) { viewStore in
			VStack(spacing: sectionElementsSpacing) {
				HStack(alignment: .top, spacing: horizontalIconToExplanationSpacing) {
					VStack(alignment: .leading, spacing: titleToSubtitleSpacing + 4) {
						Text(L10n.privacyPolicy)
							.mediumThemedFont(size: titleFontSize)
						
						Text(L10n.privacyPolicyExplainer)
							.themedFont(size: subtitleFontSize)
							.foregroundColor(.secondary)
					}
					
					Spacer()
					
					SquareButton(
						image: .image(Asset.Phosphor.eyeSlash.swiftUIImage),
						backgroundColor: .seaSalt,
						foregroundColor: .gray,
						iconOffset: 0
					) { isPresentingPrivacyPolicy = true }
						.extendFrame(.vertical)
				}
				.onTapGesture { isPresentingPrivacyPolicy = true }
				
				HStack(alignment: .top, spacing: horizontalIconToExplanationSpacing) {
					VStack(alignment: .leading, spacing: titleToSubtitleSpacing + 4) {
						Text(L10n.termsOfUse)
							.mediumThemedFont(size: titleFontSize)
						
						Text(L10n.termsOfUseExplainer)
							.themedFont(size: subtitleFontSize)
							.foregroundColor(.secondary)
					}
					
					Spacer()
					
					SquareButton(
						image: .image(Asset.Phosphor.article.swiftUIImage),
						backgroundColor: .seaSalt,
						foregroundColor: .gray,
						iconOffset: 0
					) { viewStore.send(.setWantsTermsOfUseNavigation) }
						.extendFrame(.vertical)
				}
				.onTapGesture { viewStore.send(.setWantsTermsOfUseNavigation) }
			}
			.sectionStyling
		}
	}

	@ViewBuilder
	private var localisation: some View {
		let isOnArabicLocale = Locale.autoupdatingCurrent.identifier.prefix(3) == Locale.arabic.identifier.prefix(3)
		let isOnCroatianLocale = Locale.autoupdatingCurrent.identifier.prefix(3) == Locale.croatian.identifier.prefix(3)
		let isOnFrenchLocale = Locale.autoupdatingCurrent.identifier.prefix(3) == Locale.french.identifier.prefix(3)
		let isOnGermanLocale = Locale.autoupdatingCurrent.identifier.prefix(3) == Locale.german.identifier.prefix(3)
		let isOnJapaneseLocale = Locale.autoupdatingCurrent.identifier.prefix(3) == Locale.japanese.identifier.prefix(3)
		let isOnPolishLocale = Locale.autoupdatingCurrent.identifier.prefix(3) == Locale.polish.identifier.prefix(3)
		let isOnSpanishLocale = Locale.autoupdatingCurrent.identifier.prefix(3) == Locale.spanish.identifier.prefix(3)
		let shouldDisplayLocalisationSection: Bool = isOnArabicLocale
		 || isOnCroatianLocale
		 || isOnFrenchLocale
		 || isOnGermanLocale
		 || isOnJapaneseLocale
		 || isOnPolishLocale
		 || isOnSpanishLocale
		
		if shouldDisplayLocalisationSection {
				VStack(spacing: sectionElementsSpacing) {
					HStack(alignment: .top, spacing: horizontalIconToExplanationSpacing) {
						VStack(alignment: .leading, spacing: titleToSubtitleSpacing + 4) {
							Text(L10n.localisationHeader)
								.mediumThemedFont(size: titleFontSize)
							
							Text(L10n.localisationExplainer)
								.themedFont(size: subtitleFontSize)
								.foregroundColor(.secondary)
						}
						
						Spacer()
						
						SquareButton(
							image: .image(Asset.Phosphor.translate.swiftUIImage),
							backgroundColor: .purple,
							foregroundColor: .white,
							iconOffset: 0
						) {  }
							.extendFrame(.vertical)
					}
					.onTapGesture { }
				.sectionStyling
			}
		}
		else {
			EmptyView()
		}
	}
	
	// MARK: - Presented Views
	
	private var privacySheet: some View {
		CardView {
			HStack {
				Text(L10n.privacyPolicy)
					.boldThemedFont(size: 22)
				
				Spacer()
				
				dismissalIcon
			}
		} content: {
			VStack {
				HStack {
					Text(L10n.privacyPolicyExplainer)
						.boldThemedFont(size: 16)
					Spacer()
				}
				
				Spacer()
			}
			.padding()
		}
	}
	
	// MARK: - Helpers
	
	private var dismissalIcon: some View {
		Image(systemName: "xmark.app.fill")
			.font(.system(size: 25))
			.foregroundColor(.white)
			.extendFrame(.vertical)
			.onTapGesture {
				if isPresentingPrivacyPolicy { isPresentingPrivacyPolicy = false }
				else { self.presentationMode.wrappedValue.dismiss() }
			}
	}
	
	// MARK: - Overlays
	
	public var body: some View {
		WithViewStore(store) { viewStore in
			CardView {
				HStack {
					Text(L10n.settings)
						.boldThemedFont(size: 22)
					
					Spacer()
					
					dismissalIcon
				}
			} content: {
				ScrollView {
					VStack(spacing: 15) {
						cameraControls

						shutterControls

						metadataControls
						
						generalControls
						
						appIcons(scheme: .light)
						
						appIcons(scheme: .dark)
						
						appStoreControls
						
						socials

						localisation
						
						legal
					}
					.padding()
					
					let text = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
					+ " ("
					+ (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "")
					+ ")"
					
					ZStack {
						Rectangle()
							.fill(Color.seaSalt)
							.cornerRadius(24)
							.shadow(
								color: Color(UIColor.black.withAlphaComponent(0.55)),
								radius: 2,
								x: 0,
								y: 1
							)
							.padding(-10)
							.padding(.horizontal, -10)
						
						Text(text)
							.foregroundColor(.white)
							.offset(y: 1)
						
						Text(text)
							.foregroundColor(.black)
					}
					.boldThemedFont(size: 12)
					.fixedSize()
					.padding(
						.bottom,
						lacksPhysicalHomeButton ? 10 : 25
					)
				}
			}
			.onAppear {
				viewStore.send(.begin)
			}
			.sheet(
				isPresented: viewStore.binding(
					get: \.shouldPresentProUpgradeOverlay,
					send: SettingsFeature.Action.setIsPresentingProUpgradeOverlay
				)
			) {
				UpgradeToProView(
					store: store.scope(
						state: \.shopfront,
						action: SettingsFeature.Action.shopfront
					)
				)
				.interactiveDismissDisabled(viewStore.shopfront.attemptingToCheckout)
			}
			.sheet(isPresented: $isPresentingPrivacyPolicy) { privacySheet.edgesIgnoringSafeArea(.all) }
		}
		.edgesIgnoringSafeArea(.all)
	}
	
	// MARK: - Lifecycle
	
	public init(_ store: StoreOf<SettingsFeature>) {
		self.store = store
	}
	
}

private extension View {
	var sectionStyling: some View {
		self
			.padding()
			.background(Color(hex: 0x1C1C1E))
			.cornerRadius(12)
	}

	var darkContentSectionStyling: some View {
		self
			.padding()
			.background(Color.gray)
			.cornerRadius(12)
	}
}

struct SettingsView_Preview: PreviewProvider {
	static var previews: some View {
		let settingsStore = Store(
			initialState: SettingsFeature.State(),
			reducer: SettingsFeature()
		)
		
		SettingsView(settingsStore)
			.previewLayout(.sizeThatFits)
			.preferredColorScheme(.dark)
			.registerCustomFonts()
		
		SettingsView(settingsStore)
			.environment(\.locale, .japanese)
			.previewLayout(.sizeThatFits)
			.preferredColorScheme(.dark)
			.registerCustomFonts()
	}
}

