import Foundation
import SwiftUI

public enum GradientStyling: CaseIterable {
	case cobalt
	case forest
	case gold
	case green
	case indigo
	case lime
	case primary
	case rose
	case sepia
	case turqoise
	case vermillion
	case violet
	case vitsoe
	
	public var topColor: Color {
		switch self {
		case .cobalt: return .init(hex: 0x669EFF)
		case .forest: return .init(hex: 0x62D96B)
		case .gold: return .init(hex: 0xFFC940)
		case .green: return .init(hex: 0x01ED35)
		case .indigo: return .init(hex: 0xAD99FF)
		case .lime: return .init(hex: 0xD1F26D)
		case .primary: return .init(hex: 0xFF5959)
		case .rose: return .init(hex: 0xFF66A1)
		case .sepia: return .init(hex: 0xC99765)
		case .turqoise: return .init(hex: 0x2EE6D6)
		case .vermillion: return .init(hex: 0xFF6E4A)
		case .violet: return .init(hex: 0xC274C2)
		case .vitsoe: return .init(hex: 0xF3F3F3)
		}
	}
	
	public var bottomColor: Color {
		switch self {
		case .cobalt: return .init(hex: 0x1A3E7E)
		case .forest: return .init(hex: 0x1D7324)
		case .gold: return .init(hex: 0x745507)
		case .green: return .init(hex: 0x01861E)
		case .indigo: return .init(hex: 0x3E3077)
		case .lime: return .init(hex: 0x728C23)
		case .primary: return .init(.init(red: 255.0/255.0, green: 2.0/255.0, blue: 84.0/255.0, alpha: 1.0))
		case .rose: return .init(hex: 0xA82255)
		case .sepia: return .init(hex: 0x63411E)
		case .turqoise: return .init(hex: 0x008075)
		case .vermillion: return .init(hex: 0x9E2B0E)
		case .violet: return .init(hex: 0x5C255C)
		case .vitsoe: return .init(hex: 0x8F8F8F)
		}
	}
	
	public var foregroundColor: Color {
		switch self {
		case .cobalt: return .init(hex: 0x10264D)
		case .forest: return .init(hex: 0x144E19)
		case .gold: return .init(hex: 0x5A4205)
		case .green: return .init(hex: 0x015815)
		case .indigo: return .init(hex: 0x2E2358)
		case .lime: return .init(hex: 0x576A1B)
		case .primary: return .init(hex: 0x810029)
		case .rose: return .init(hex: 0x72173A)
		case .sepia: return .init(hex: 0x4F3418)
		case .turqoise: return .init(hex: 0x01554E)
		case .vermillion: return .init(hex: 0x611C0A)
		case .violet: return .init(hex: 0x371737)
		case .vitsoe: return .init(hex: 0x525252)
		}
	}
}
