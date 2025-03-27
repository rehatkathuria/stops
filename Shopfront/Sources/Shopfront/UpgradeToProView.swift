import Aesthetics
import ComposableArchitecture
import Foundation
import OverlayView
import Pow
import Shared
import StoreKit
import SwiftUI
import Views

struct AppIconModel: Codable, Identifiable {
	let id: UUID
	let icon: AppIcon
}

public struct UpgradeToProView: View {
	
	@Environment(\.lacksPhysicalHomeButton) var lacksPhysicalHomeButton
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	
	private let store: StoreOf<ShopfrontFeature>
	private var colourProfilesRows: Array<GridItem> {
		.init(
			repeating: .init(
				spacing: 80,
				alignment: .center
			),
			count: 4
		)
	}
	
	private var gridRows: Array<GridItem> {
		.init(
			repeating: .init(
				spacing: 0,
				alignment: .center
			),
			count: 4
		)
	}
	
	private let appIcons: [AppIconModel]
	private var lazyGridSpacing = CGFloat(15)
	
	@State private var quantizations: Quantization = .chromatic(.folia)
	@State private var imageContainerSize = CGSize.zero
	
	// MARK: - View(s)
	
	private var profiles: some View {
		WithViewStore(store) { viewStore in
			ZStack {
				Color
					.clear
					.extendFrame()
					.onSizeChange({ imageContainerSize = $0 })
				
				Group {
					if viewStore.shouldAllowExamplesIteration {
						Group {
							switch viewStore.attemptedCaptureQuantization {
							case .chromatic(.folia): Asset.IAPUpgradeExamples.folia.swiftUIImage.resizable()
							case .chromatic(.supergold): Asset.IAPUpgradeExamples.supergold.swiftUIImage.resizable()
							case .monochrome: Asset.IAPUpgradeExamples.monochrome.swiftUIImage.resizable()
							default: Asset.IAPUpgradeExamples.folia.swiftUIImage.resizable()
							}
						}
						.aspectRatio(contentMode: .fill)
						.overlay {
							VStack {
								Spacer()
								Spacer()
								
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
										.padding(.horizontal, -5)
									
									let text = localisedDisplayableName(viewStore.attemptedCaptureQuantization) ?? ""
									Text(text)
										.foregroundColor(.white)
										.offset(y: 1)
									
									Text(text)
										.foregroundColor(.black)
								}
								.boldThemedFont(size: 14)
								.fixedSize()
								
								Spacer()
								Spacer()
								Spacer()
								Spacer()
								Spacer()
								
							}
						}
						.onTapGesture {
							viewStore.send(.iterateQuantizationExample)
						}
					}
					else {
						PrivateImageView(
							frame: .init(origin: .zero, size: imageContainerSize),
							image: viewStore.attemptedToCapture,
							contentMode: .resizeAspectFill
						)
						.border(.white, width: 4)
						.padding()
						.padding(.bottom)
						.padding(.bottom)
					}
				}
			}
		}
	}
	
	private var customIcons: some View {
		LazyVGrid(columns: gridRows, spacing: lazyGridSpacing) {
			ForEach(appIcons) { icon in
				PulsingIconView(icon: icon)
			}
		}
	}
	
	// MARK: - Products
	
	@ViewBuilder
	private func productInfo(
		_ product: Product,
		selected: Bool
	) -> some View {
		VStack(alignment: .center) {
			Group {
				let split = productName(product).split(separator: " ")
				
				ForEach(Array(zip(split.indices, split)), id: \.0) { index, item in
					let isDurationDigit = index == 0
					Text(item)
						.foregroundColor(
							isDurationDigit ? .orange : .white
						)
						.font(
							isDurationDigit
							? Font.system(size: 30, weight: .bold, design: .monospaced)
							: Font.custom("Circular Std", size: 16).weight(.bold)
						)
				}
				
				HStack(spacing: 0) {
					Text(product.displayPrice)
					Text(productDuration(product))
				}
				.boldThemedFont(size: 16)
				
				if selected {
					Group {
						if product.id == Product.Pro.yearly {
							Text("44% " + L10n.savings)
								.pricingBlurbStyling(.green)
						}
						else if product.id == Product.Pro.monthly {
							Text(L10n.fun)
								.pricingBlurbStyling(.orange)
						}
					}
				}
			}
			.foregroundColor(.orange)
		}
	}
	
	private var products: some View {
		HStack(spacing: 0) {
			WithViewStore(store) { viewStore in
				HStack(spacing: 0) {
					ForEach(viewStore.products.sorted(by: \.price), id: \.id) { product in
						let selected = viewStore.selected?.id == product.id
						
						HStack(spacing: 0) {
							productInfo(product, selected: selected)
								.extendFrame()
								.background(Color(hex: 0x1e1e1e))
								.border(
									selected ? .orange : .clear,
									width: selected ? 6 : 0
								)
								.onTapGesture { viewStore.send(.select(product)) }
							
							if product != viewStore.products.last {
								Rectangle()
									.fill(Color.black)
									.extendFrame(.vertical)
									.frame(width: 2)
									.padding(.vertical, -2)
								
								Rectangle()
									.fill(Color(theme.cardBorderStripColor))
									.extendFrame(.vertical)
									.frame(width: 1)
									.padding(.vertical, -1)
							}
						}
					}
				}
				.extendFrame()
				.background(Color(hex: 0x1e1e1e))
			}
		}
		.background(Color(hex: 0x1e1e1e))
		.padding(.horizontal, -2)
		.frame(height: 180)
	}
	
	// MARK: - View
	
	public var body: some View {
		CardView {
			WithViewStore(store) { viewStore in
				HStack {
					Group {
						switch viewStore.page {
						case .colourProfiles:
							QuantizationsView()
								.mask(
									HStack {
										Text(L10n.quantizationAlgorithms)
										Spacer()
									}
								)
						case .customAppIcons:
							Text(L10n.customAppIcons)
						}
					}
					.boldThemedFont(size: 18)
					
					Spacer()
					
					Image(systemName: "xmark.app.fill")
						.font(.system(size: 25))
						.foregroundColor(.white)
						.extendFrame(.vertical)
						.onTapGesture {
							guard viewStore.attemptingToCheckout == false else { return }
							self.presentationMode.wrappedValue.dismiss()
						}
				}
			}
		} content: {
			WithViewStore(store) { viewStore in
				VStack(spacing: 0) {
					TabView(
						selection: viewStore.binding(
							get: \.page,
							send: ShopfrontFeature.Action.setPage
						)
					) {
						profiles
							.clipped()
							.tag(ProBenefits.colourProfiles)
						
						customIcons
							.dimmingOverlay
							.tag(ProBenefits.customAppIcons)
					}
					.tabViewStyle(.page)
					.frame(minHeight: 200)
					
					separator(.init())
						.frame(maxWidth: .infinity)
					
					products
					
					separator(.init())
						.frame(maxWidth: .infinity)
					
					Spacer()
					
					HStack(alignment: .center) {
						Group {
							SquareButton(
								image: .image(Asset.PhosphorFill.lightningFill.swiftUIImage),
								backgroundColor: .orange,
								foregroundColor: .black,
								iconSize: 34
							) { }
								.padding(.trailing, 5)
							
							ZStack {
								Group {
									let text = "Stops Pro"
									
									Text(text)
										.foregroundColor(.black)
										.offset(y: 1)
									
									Text(text)
								}
								.boldThemedFont(size: 22)
							}
							
							Spacer()
							
							ChunkyButton(
								.primary,
								.text(L10n.continue),
								callToActionHidden: viewStore.attemptingToCheckout,
								height: 45
							) {
								viewStore.send(.purchaseSelected)
							}
							.overlay(isShown: viewStore.attemptingToCheckout) {
								ProgressView()
									.foregroundColor(.white)
									.controlSize(.regular)
							}
						}
						.offset(y: lacksPhysicalHomeButton ? -5 : 0)
					}
					.padding(.horizontal)
					.padding(.vertical, 5)
					.padding(.bottom, lacksPhysicalHomeButton ? 0 : 10)
					.onAppear {
						viewStore.send(.load)
					}
				}
			}
		}
		.edgesIgnoringSafeArea(.all)
	}
	
	// MARK: - Lifecycle
	
	public init(store: StoreOf<ShopfrontFeature>) {
		self.store = store
		self.appIcons = (
			AppIcon.allCases
			+ AppIcon.allCases
		).map({ icon in .init(id: UUID(), icon: icon) })
	}
	
	// MARK: - Helpers
	
	private func productName(_ product: Product) -> String {
		if product.id == Product.Pro.yearly {
			return L10n._12Months
		}
		else { return L10n._1Month }
	}
	
	private func productDuration(_ product: Product) -> String {
		if product.id == Product.Pro.yearly {
			return L10n.perYear
		}
		else { return L10n.perMonth }
	}

	private func localisedDisplayableName(_ quantization: Quantization) -> String? {
		switch quantization {
		case .chromatic(let chromatic):
			switch chromatic {
			case .folia: return L10n.folia
			case .supergold: return L10n.supergold
			default: break
			}
		case .dither: break
		case .monochrome: return L10n.monochrome
		case .warhol(let warhol):
			switch warhol {
			case .bubblegum: break
			case .darkroom: break
			case .glowInTheDark: return L10n.quirky
			case .habenero: break
			}
		}
		
		return nil
	}
	
}

struct UpgradeToProView_Preview: PreviewProvider {
	static var previews: some View {
		let store = Store(initialState: ShopfrontFeature.State(page: .colourProfiles), reducer: ShopfrontFeature())
		
		UpgradeToProView(store: store)
			.previewLayout(.sizeThatFits)
			.preferredColorScheme(.dark)
			.registerCustomFonts()
	}
}

fileprivate extension View {
	@ViewBuilder
	func pricingBlurbStyling(_ bg: Color) -> some View {
		self
			.boldThemedFont(size: 12)
			.foregroundColor(.black)
			.background(
				bg
					.cornerRadius(8)
					.padding(-7)
			)
			.padding(.top, 5)
			.transition(
				.identity
					.animation(.linear(duration: 1).delay(2))
					.combined(
						with: .movingParts.anvil
					)
			)
	}
	
	var dimmingOverlay: some View {
		self
			.overlay {
				Color
					.black
					.opacity(0)
			}
	}
}

public struct PulsingIconView: View  {
	@State private var tapTicker = UUID()
	private let icon: AppIconModel
	
	init(icon: AppIconModel) { self.icon = icon }
	
	public var body: some View {
		icon
			.icon
			.swiftUIImage
			.background(.clear)
			.frame(dimension: 70)
			.cornerRadius(9)
			.shadow(
				color: Color(
					UIColor.black.withAlphaComponent(0.55)
				),
				radius: 1,
				x: 0,
				y: 1
			)
			.zIndex(-4)
			.onTapGesture {
				tapTicker = .init()
			}
			.changeEffect(
				.pulse(
					shape: RoundedRectangle(
						cornerRadius: 8,
						style: .circular
					),
					drawingMode: .fill,
					count: 2
				),
				value: tapTicker
			)
	}
}

import Shiny

public struct QuantizationsView: UIViewRepresentable {
	public func makeUIView(context: Context) -> ShinyView {
		let shinyView = ShinyView(frame: UIScreen.main.bounds)
		shinyView.colors = [.link, .yellow, .red, .green, .blue, .lightGray]
		shinyView.startUpdates() // necessary
		return shinyView
	}
	
	public func updateUIView(_ uiView: ShinyView, context: Context) {
		
	}
	
	public typealias UIViewType = ShinyView
	
}
