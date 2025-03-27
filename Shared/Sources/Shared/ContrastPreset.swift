import Foundation

public enum ContrastPreset: String, Identifiable, CaseIterable {
	public var id: Self { self }
	
	case faded
	case neutral
	case punchy
}
