import Foundation
import UIKit.UICollectionView

enum AssetLayoutStyle {
	case grid
	case detailed
	
	func recalculate(layout: UICollectionViewFlowLayout, inBoundingSize size: CGSize) {
		switch self {
		case .grid:
			layout.minimumLineSpacing = 15
			layout.minimumInteritemSpacing = 1
			layout.sectionInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
			let width = (size.width / 2.5) - (15 * 3)
			layout.itemSize = .init(
				width: width,
				height: width
			)
		case .detailed:
			layout.minimumLineSpacing = 0
			layout.minimumInteritemSpacing = 0
			layout.sectionInset = UIEdgeInsets.zero
			layout.scrollDirection = .horizontal;
			layout.itemSize = size
		}
	}
}
