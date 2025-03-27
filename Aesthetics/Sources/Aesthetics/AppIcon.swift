import Foundation
import UIKit.UIImage
import SwiftUI

public enum AppIcon: String, CaseIterable, Identifiable, Codable {
	/// Light
	case primary = "AppIcon"
	case primaryNoBlob = "AppIconNoBlob"
	case beige = "AppIconBeige"
	case beigeNoBlob = "AppIconBeigeNoBlob"
	case blue = "AppIconBlue"
	case blueNoBlob = "AppIconBlueNoBlob"
	case yellow = "AppIconYellow"
	case yellowNoBlob = "AppIconYellowNoBlob"

	/// Dark
	case darkAppIcon = "DarkAppIcon"
	case darkAppIconNoBlob = "DarkAppIconNoBlob"
	case darkBeige = "DarkAppIconBeige"
	case darkBeigeNoBlob = "DarkAppIconBeigeNoBlob"
	case darkBlue = "DarkAppIconBlue"
	case darkBlueNoBlob = "DarkAppIconBlueNoBlob"
	case darkYellow = "DarkAppIconYellow"
	case darkYelloNoBlob = "DarkAppIconYellowNoBlob"
	
	public var id: String { rawValue }
	
	public var iconName: String? {
		switch self {
		case .primary: return nil
		default: return rawValue
		}
	}
	
	public var preview: UIImage {
		switch self {
		case .primary:
			return UIImage(named: "AppIconPrimaryHighResolutionPreview") ?? UIImage()
		default:
			return UIImage(named: rawValue) ?? UIImage()
		}
	}
	
	@ViewBuilder
	public var swiftUIImage: Image {
		Image(uiImage: preview)
			.resizable()
	}
	
	public static var lightIcons: [AppIcon] = [
		.primary,
		.primaryNoBlob,
		.beige,
		.beigeNoBlob,
		.blue,
		.blueNoBlob,
		.yellow,
		.yellowNoBlob
	]

	public static var darkIcons: [AppIcon] = [
		.darkAppIcon,
		.darkAppIconNoBlob,
		.darkBeige,
		.darkBeigeNoBlob,
		.darkBlue,
		.darkBlueNoBlob,
		.darkYellow,
		.darkYelloNoBlob
	]
}
