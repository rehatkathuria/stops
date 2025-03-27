import AVFoundation
import UIKit
import SwiftUI
import Views

final class AssetCell: UICollectionViewCell, UIGestureRecognizerDelegate {
	
	var layoutStyle: AssetLayoutStyle?
	var assetIdentifier: String = ""
	var shouldAllowLongPress: Bool?
	let imageView: UIImageView
	let playerLayer: AVPlayerLayer
	var asset: AVAsset?
	
	override init(frame: CGRect) {
		imageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
		imageView.clipsToBounds = true
		playerLayer = .init()
		playerLayer.masksToBounds = true
		super.init(frame: frame)
		backgroundView = imageView
		contentView.layer.addSublayer(playerLayer)
	}
	
	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		switch layoutStyle {
		case .none: break
		case .grid:
			imageView.frame = contentView.bounds
			imageView.contentMode = .scaleAspectFill
		case .detailed:
			imageView.contentMode = .scaleAspectFit
			imageView.frame = .init(
				x: 0,
				y: 0,
				width: contentView.bounds.width.eightTenths,
				height: contentView.bounds.height.eightTenths
			)
			imageView.center = contentView.center
		}
		
		playerLayer.frame = imageView.frame
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		shouldAllowLongPress = nil
		imageView.image = nil
		assetIdentifier = ""
		layoutStyle = nil
		playerLayer.player = nil
		asset = nil
	}
	
	// MARK: - UIGestureRecognizerDelegate
	
	override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		shouldAllowLongPress ?? false
	}
}
