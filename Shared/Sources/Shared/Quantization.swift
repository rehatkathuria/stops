import Foundation

public enum Quantization: Equatable, Hashable, Identifiable {
	
	public var id: String { name }
	
	// MARK: - Substructures

	enum Keys: String {
		case chromatic
		case dither
		case monochrome
		case warhol
	}
	
	public enum Minor: Equatable {
		case chromatic(ChromaticTransformation)
		case warhol(WarholTransformation)
		
		var name: String {
			switch self {
			case .chromatic(let transformation): return transformation.rawValue
			case .warhol(let transformation): return transformation.rawValue
			}
		}
	}
	
	case chromatic(ChromaticTransformation)
	case dither
	case monochrome
	case warhol(WarholTransformation)
	
	public var hasAssociatedVariable: Bool {
		switch self {
		case .dither, .monochrome: return false
		case .chromatic, .warhol: return true
		}
	}

	public var isProtectedByIAP: Bool {
		switch self {
		case .chromatic(.tonachrome): return false
		default: return true
		}
	}
	
	public var minor: Minor? {
		switch self {
		case .dither, .monochrome: return nil
		case .chromatic(let transformation): return .chromatic(transformation)
		case .warhol(let transformation): return .warhol(transformation)
		}
	}
	
	public var displayableName: String {
		switch self {
		case .chromatic(let chromaticTransformation):
			switch chromaticTransformation {
			case .folia: return "Folia"
			case .supergold: return "Supergold"
			case .tonachrome: return "Tonachrome"
			}
		case .dither: return "Dither"
		case .monochrome: return "Monochrome"
		case .warhol: return "Quirky"
		}
	}
	
	public var name: String {
		switch self {
		case .chromatic(let transformation):
			switch transformation {
			case .folia:
				return Keys.chromatic.rawValue + "." + ChromaticTransformation.folia.rawValue
			case .supergold:
				return Keys.chromatic.rawValue + "." + ChromaticTransformation.supergold.rawValue
			case .tonachrome:
				return Keys.chromatic.rawValue + "." + ChromaticTransformation.tonachrome.rawValue
			}
		case .dither: return Keys.dither.rawValue
		case .monochrome: return Keys.monochrome.rawValue
		case .warhol(let warhol):
			switch warhol {
			case .bubblegum: return Keys.warhol.rawValue + "." + WarholTransformation.bubblegum.rawValue
			case .darkroom: return Keys.warhol.rawValue + "." + WarholTransformation.darkroom.rawValue
			case .glowInTheDark: return Keys.warhol.rawValue + "." + WarholTransformation.glowInTheDark.rawValue
			case .habenero: return Keys.warhol.rawValue + "." + WarholTransformation.habenero.rawValue
			}
		}
	}
	
	public static func quantizationFromName(_ name: String) -> Quantization? {
		switch name {
		case Keys.chromatic.rawValue + "." + ChromaticTransformation.folia.rawValue: return .chromatic(.folia)
		case Keys.chromatic.rawValue + "." + ChromaticTransformation.supergold.rawValue: return .chromatic(.supergold)
		case Keys.chromatic.rawValue + "." + ChromaticTransformation.tonachrome.rawValue: return .chromatic(.tonachrome)
		case Keys.dither.rawValue: return .dither
		case Keys.monochrome.rawValue: return .monochrome
		case Keys.warhol.rawValue + "." + WarholTransformation.bubblegum.rawValue: return .warhol(.bubblegum)
		case Keys.warhol.rawValue + "." + WarholTransformation.darkroom.rawValue: return .warhol(.darkroom)
		case Keys.warhol.rawValue + "." + WarholTransformation.glowInTheDark.rawValue: return .warhol(.glowInTheDark)
		case Keys.warhol.rawValue + "." + WarholTransformation.habenero.rawValue: return .warhol(.habenero)
		default: break
		}
		return nil
	}
	
}
