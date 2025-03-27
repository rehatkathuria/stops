import Foundation

public struct StopsEXIF: Codable {

	public static let containerName = "{STOPS}"
	
	// MARK: - Substructures
	
	public enum Keys: String, CodingKey {
		case grain
		case minor
		case quantization
		case version
	}
	
	// MARK: - Properties
	
	public let grain: GrainPresence
	public let quantization: Quantization
	public let version: String
	
	public init(
		grain: GrainPresence,
		quantization: Quantization
	) {
		self.grain = grain
		self.quantization = quantization
		self.version = "1.0"
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Keys.self)
		let grainKey = try container.decode(String.self, forKey: .grain)
		let quantizationKey = try container.decode(String.self, forKey: .quantization)
		let versionKey = try container.decode(String.self, forKey: .version)
		
		guard
			let grain = GrainPresence(rawValue: grainKey),
			let quantization = Quantization.quantizationFromName(quantizationKey)
		else {
			throw DecodingError.dataCorrupted(
				.init(
					codingPath: [
						Keys.grain,
						Keys.quantization
					],
					debugDescription: "Missing one of these two values"
				)
			)
		}
		
		self.grain = grain
		self.quantization = quantization
		self.version = versionKey
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: Keys.self)
		try container.encode(grain.rawValue, forKey: .grain)
		try container.encode(quantization.name, forKey: .quantization)
	}
	
	public var dictionaryRepresenation: [String: Any] {
		var dictionary = [
			Keys.grain.rawValue: grain.rawValue,
			Keys.quantization.rawValue: quantization.name,
			Keys.version.rawValue: version
		]
		if let minor = quantization.minor {
			dictionary[Keys.minor.rawValue] = minor.name
		}
		return dictionary
	}
	
}
