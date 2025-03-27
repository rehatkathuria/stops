import CoreImage
import Shared

public struct Transformation: Equatable {
	let name: String
	public let transform: (CIImage) -> (CIImage)
	public let preferredGrainPresence: GrainPresence
	public let preferredQuantization: Quantization
	
	public static func ==(lhs: Transformation, rhs: Transformation) -> Bool {
		lhs.name == rhs.name
			&& lhs.preferredQuantization == rhs.preferredQuantization
	}
	
	public init(
		_ preferredGrainPresence: GrainPresence,
		_ preferredQuantization: Quantization
	) {
		self.preferredGrainPresence = preferredGrainPresence
		self.preferredQuantization = preferredQuantization
		
		self.name = ""
			.appending(preferredQuantization.name)
			.appending(preferredGrainPresence.rawValue)
		
		self.transform = { incoming in
			var img = incoming
			
			
			switch preferredQuantization {
			case .chromatic:
				img = noise(img, preferredGrainPresence)
			case .dither: break
			case .monochrome:
				img = noise(img, preferredGrainPresence)
			case .warhol:
				img = noise(img, preferredGrainPresence)
			}
			
			img = regulate(img)
			
			return img
		}
	}
}


extension CGAffineTransform {
	init(rotationAngle: CGFloat, anchor: CGPoint) {
		self.init(
			a: cos(rotationAngle),
			b: sin(rotationAngle),
			c: -sin(rotationAngle),
			d: cos(rotationAngle),
			tx: anchor.x - anchor.x * cos(rotationAngle) + anchor.y * sin(rotationAngle),
			ty: anchor.y - anchor.x * sin(rotationAngle) - anchor.y * cos(rotationAngle)
		)
	}
	
	func rotated(by angle: CGFloat, anchor: CGPoint) -> Self {
		let transform = Self(rotationAngle: angle, anchor: anchor)
		return self.concatenating(transform)
	}
}
