import Aesthetics
import ComposableArchitecture
import Foundation
import Shared
import SwiftUI
import UIKit
import Views

fileprivate var theme = Theme()

public final class OverlayViewController: UIViewController {
	private let store: Store<OverlayFeature.State, OverlayFeature.Action>
	private let styling: OverlayView.Styling
	private var child: UIViewController?
	
	public init(
		store: Store<OverlayFeature.State, OverlayFeature.Action>,
		styling: OverlayView.Styling
	) {
		self.store = store
		self.styling = styling
		super.init(nibName: nil, bundle: nil)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) { fatalError() }
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		let hostingController = UIHostingController(
			rootView: OverlayView(
				store: store,
				styling: styling
			)
		)
		hostingController.view.backgroundColor = .clear
		
		addChild(hostingController)
		hostingController.willMove(toParent: self)
		view.addSubview(hostingController.view)
		hostingController.didMove(toParent: self)
		child = hostingController
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		child?.view.frame = view.bounds
	}
}

public struct OverlayView: View {
	
	// MARK: - Substructures
	
	public struct Configuration: Identifiable, Equatable {
		public static func ==(
			lhs: OverlayView.Configuration,
			rhs: OverlayView.Configuration
		) -> Bool { lhs.title == rhs.title }
		
		public var id: String { title }
		
		public indirect enum Image {
			case systemName(String)
			case image(SwiftUI.Image)
		}
		
		public let action: () -> Void
		public let buttonColor: Color
		public let buttonOverlayColor: Color
		public let image: Image
		public let title: String
		public let subtitle: String
		public let selected: Bool
		public let iconXOffset: CGFloat
		public let iconYOffset: CGFloat
		
		public init(
			action: @escaping () -> Void,
			buttonColor: Color,
			buttonOverlayColor: Color = .white,
			image: Image,
			title: String,
			subtitle: String,
			selected: Bool = false,
			iconXOffset: CGFloat = 0.5,
			iconYOffset: CGFloat = 0.5
		) {
			self.action = action
			self.buttonColor = buttonColor
			self.buttonOverlayColor = buttonOverlayColor
			self.image = image
			self.title = title
			self.subtitle = subtitle
			self.selected = selected
			self.iconXOffset = iconXOffset
			self.iconYOffset = iconYOffset
		}
	}
	
	public enum Styling {
		case rows(IdentifiedArrayOf<Configuration>)
		case view(AnyView)
	}
	
	// MARK: - Properties
	
	private let store: Store<OverlayFeature.State, OverlayFeature.Action>
	private let cornerRadius = max(8, UIScreen.main.displayCornerRadius)
	private let styling: Styling

	@State private var contentsSize = CGSize.zero
	@State private var offset: CGFloat = UIScreen.main.bounds.width
	@State private var dismissalOpacity: CGFloat = 0
	@State private var draggingPadding: CGFloat = 0
	
	@Environment(\.lacksPhysicalHomeButton) var lacksPhysicalHomeButton

	public init(
		store: Store<OverlayFeature.State, OverlayFeature.Action>,
		styling: Styling
	) {
		self.store = store
		self.styling = styling
	}

	private func horizontalRow(
		buttonColor: Color,
		buttonOverlayColor: Color,
		image: OverlayView.Configuration.Image,
		title: String,
		subtitle: String,
		selected: Bool,
		iconXOffset: CGFloat,
		iconYOffset: CGFloat
	) -> some View {
		HStack(alignment: .top, spacing: 20) {
			leadingIcon(image: image, backgroundColor: buttonColor, foregroundColor: buttonOverlayColor)
				.overlay(isShown: selected, alignment: .topTrailing) {
					SealCheckmark()
						.offset(x: 10, y: -10)
				}

			VStack(alignment: .leading) {
				Text(title)
					.titleStyling

				Text(subtitle)
					.subtitleStyling
			}
			.offset(y: -4)

			Spacer()
		}
		.padding()
		.padding(.top, 4)
		.padding(.leading, 10)
	}
	
	public var body: some View {
			ZStack(alignment: .bottom) {
				WithViewStore(store) { viewStore in
					Color.clear
						.onChange(of: viewStore.isActive, perform: { isActive in
							offset = isActive ? 0 : contentsSize.height + contentsSize.width.half
							dismissalOpacity = viewStore.isActive ? 0.6 : 0.0
						})
						.onAppear(perform: {
							offset = viewStore.isActive ? 0 : contentsSize.height + contentsSize.width.half
							dismissalOpacity = viewStore.isActive ? 0.6 : 0.0
						})
					
					if viewStore.isForefront {
						Rectangle()
							.fill(.black)
							.opacity(dismissalOpacity)
							.animation(.default, value: dismissalOpacity)
							.frame(maxWidth: .infinity, maxHeight: .infinity)
							.onTapGesture(perform: { viewStore.send(.didRequestDismissal) })
					}
				}
				
				ZStack(alignment: .bottom) {
					Group {
						switch styling {
						case .rows(let rows):
							VStack(alignment: .leading, spacing: 0) {
								ForEach(rows.indices, id: \.self) { row in
									horizontalRow(
										buttonColor: rows[row].buttonColor,
										buttonOverlayColor: rows[row].buttonOverlayColor,
										image: rows[row].image,
										title: rows[row].title,
										subtitle: rows[row].subtitle,
										selected: rows[row].selected,
										iconXOffset: rows[row].iconXOffset,
										iconYOffset: rows[row].iconYOffset
									)
									.background(Color.black.opacity(0.001)) /// Make SwiftUI extend to the edge of the target
									.padding(.bottom, (rows[row] == rows.last && lacksPhysicalHomeButton) ? 10 : 0)
									.padding(.bottom, rows[row] == rows.last ? draggingPadding : 0)
									.padding(.top, (rows[row] == rows.first) ? 5 : 0)
									.onTapGesture { rows[row].action() }
									
									if row < rows.index(before: rows.endIndex) {
										separator(theme)
											.frame(maxWidth: .infinity)
									}
								}
							}
							
						case .view(let view):
							view
						}
					}
					.onSizeChange { size in contentsSize = size }
					.padding(.vertical, 7)
					.background(BaseView().allowsHitTesting(false))
				}
				.simultaneousGesture(
					DragGesture(minimumDistance: 0, coordinateSpace: .global)
						.onChanged { value in
							let initial = (value.location.y - value.startLocation.y)
							
							if (initial <= 0) {
								draggingPadding = abs(initial * 0.15)
								offset = 0
							}
							else {
								draggingPadding = 0
								offset = initial * 0.65
							}
						}
						.onEnded { value in
							if (value.velocity.y) <= -330 {
								ViewStore(store).send(.didRequestFlickDismissal)
							}
							else {
								draggingPadding = 0
								offset = 0
							}
						}
				)
				.offset(y: offset)
				.animation(
					.springable,
					value: offset
				)
				.animation(
					.spring(
						response: 0.45,
						dampingFraction: 0.40
					),
					value: draggingPadding
				)
				.ignoresSafeArea(.all)
			}
			.ignoresSafeArea()
	}
}

fileprivate extension View {
	func leadingIcon(
		image: OverlayView.Configuration.Image,
		backgroundColor: Color = .red,
		foregroundColor: Color,
		iconSize: CGFloat = 40,
		iconXOffset: CGFloat = 0.5,
		iconYOffset: CGFloat = 0.5
	) -> some View {
		ZStack {
			RoundedRectangle(
				cornerRadius: 9,
				style: .circular
			)
				.fill(backgroundColor)
				.frame(width: iconSize, height: iconSize, alignment: .center)
				.shadow(
					color: Color(.black.withAlphaComponent(0.5)),
					radius: 1,
					y: 1
				)

			Group {
				switch image {
				case .systemName(let systemName): Image(systemName: systemName)
				case .image(let image):
					image
						.renderingMode(.template)
						.resizable()
						.frame(dimension: iconSize * 0.6)
				}
			}
				.foregroundColor(foregroundColor)
				.imageScale(.large)
//				.offset(x: iconXOffset, y: iconYOffset)
		}
	}

	var titleStyling: some View {
		self
			.foregroundColor(.white)
			.themedFont(size: 16)
			.multilineTextAlignment(.leading)
	}

	var subtitleStyling: some View {
		self
			.foregroundColor(Color(.lightGray))
			.themedFont(size: 14)
			.multilineTextAlignment(.leading)
			.fixedSize(horizontal: false, vertical: true)
	}
}

public struct BaseView: UIViewRepresentable {
	public typealias UIViewType = BaseUIView
	public func makeUIView(context: Context) -> BaseUIView { .init(frame: .zero) }
	public func updateUIView(_ uiView: BaseUIView, context: Context) { }
}

public final class BaseUIView: UIView {
	private let blackBaseView = UIView(frame: .zero)
	private let innerContainerView = UIView(frame: .zero)
	private var cornerRadii = max(8, UIScreen.main.displayCornerRadius)
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		blackBaseView.layer.cornerCurve = .continuous
		blackBaseView.layer.cornerRadius = cornerRadii
		blackBaseView.backgroundColor = theme.cardBorderBackgroundColor
		addSubview(blackBaseView)
		
		innerContainerView.layer.cornerCurve = .continuous
		innerContainerView.layer.cornerRadius = cornerRadii
		innerContainerView.layer.borderColor = theme.cardBorderStripColor.cgColor
		innerContainerView.layer.borderWidth = 1
		innerContainerView.backgroundColor = theme.cardInnerContainerBackgroundColor
		addSubview(innerContainerView)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) { fatalError("Unavailable") }
	
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		blackBaseView.frame = bounds
		innerContainerView.frame = .init(x: 0, y: 0, width: bounds.width - 2, height: bounds.height - 3)
		innerContainerView.center = center
	}
	
}

extension DragGesture.Value {
	var velocity: CGPoint {
		let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue,
				d = decelerationRate/(1000.0*(1.0 - decelerationRate))
		
		return CGPoint(x: (location.x - predictedEndLocation.x)/d,
									 y: (location.y - predictedEndLocation.y)/d)
	}
}
