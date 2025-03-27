import SwiftUI

public enum SymmetricHStackSpacingDistribution {
	case around
	case between
}

public struct SymmetricHStack<Content: View, Leading: View, Trailing: View>: View {
	var alignment = VerticalAlignment.center
	var spacingDistribution = SymmetricHStackSpacingDistribution.between
	var spacing: CGFloat?
	
	@ViewBuilder var content: () -> Content
	@ViewBuilder var leading: () -> Leading
	@ViewBuilder var trailing: () -> Trailing
	
	public init(
		alignment: VerticalAlignment = .center,
		spacingDistribution: SymmetricHStackSpacingDistribution = .between,
		spacing: CGFloat? = nil,
		@ViewBuilder content: @escaping () -> Content,
		@ViewBuilder leading: @escaping () -> Leading,
		@ViewBuilder trailing: @escaping () -> Trailing
	) {
		self.alignment = alignment
		self.spacingDistribution = spacingDistribution
		self.spacing = spacing
		self.content = content
		self.leading = leading
		self.trailing = trailing
	}
	
	public var body: some View {
		HStack(alignment: alignment, spacing: spacing) {
			if spacingDistribution == .around {
				Spacer(minLength: 0)
			}
			
			ZStack(alignment: .leading) {
				trailing().hidden()
				leading()
			}
			
			Spacer(minLength: 0)
			
			content()
			
			Spacer(minLength: 0)
			
			ZStack(alignment: .trailing) {
				leading().hidden()
				trailing()
			}
			
			if spacingDistribution == .around {
				Spacer(minLength: 0)
			}
		}
	}
}

public extension SymmetricHStack where Leading == EmptyView {
	init(
		alignment: VerticalAlignment = .center,
		spacingDistribution: SymmetricHStackSpacingDistribution = .between,
		spacing: CGFloat? = nil,
		@ViewBuilder content: @escaping () -> Content,
		@ViewBuilder trailing: @escaping () -> Trailing
	) {
		self.alignment = alignment
		self.spacingDistribution = spacingDistribution
		self.spacing = spacing
		self.content = content
		self.leading = EmptyView.init
		self.trailing = trailing
	}
}

public extension SymmetricHStack where Trailing == EmptyView {
	init(
		alignment: VerticalAlignment = .center,
		spacingDistribution: SymmetricHStackSpacingDistribution = .between,
		spacing: CGFloat? = nil,
		@ViewBuilder content: @escaping () -> Content,
		@ViewBuilder leading: @escaping () -> Leading
	) {
		self.alignment = alignment
		self.spacingDistribution = spacingDistribution
		self.spacing = spacing
		self.content = content
		self.leading = leading
		self.trailing = EmptyView.init
	}
}
