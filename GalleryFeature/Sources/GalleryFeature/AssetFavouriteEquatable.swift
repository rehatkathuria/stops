import Foundation
import Photos

public struct AssetFavouriteEquatable: Equatable {
	public static func ==(lhs: AssetFavouriteEquatable, rhs: AssetFavouriteEquatable) -> Bool {
		lhs.rawValue.localIdentifier == rhs.rawValue.localIdentifier &&
		lhs.rawValue.isFavorite == rhs.rawValue.isFavorite
	}
	
	public let rawValue: PHAsset
}
