import Aesthetics
import SceneKit
import SwiftUI
import UIKit

public struct StarParticlesRepresentable: UIViewRepresentable {
	public init() { }
	
	public func makeUIView(context: Context) -> GlobeView {
		let view = GlobeView(frame: .zero)
		view.setCameraPosition(.revealed)
		return view
	}
	
	public func updateUIView(_ uiView: GlobeView, context: Context) {
		uiView.frame.size = uiView.superview?.frame.size ?? uiView.frame.size
	}
	
	public typealias UIViewType = GlobeView
	
}

public final class StarParticles: SCNParticleSystem {
	override public init() {
		super.init()
		birthRate = 150
		warmupDuration = 20
		birthLocation = .volume
		emitterShape = SCNPlane(width: 300, height: 300)
		particleLifeSpan = 450
		acceleration = .init(0, 0, 1.0)
		speedFactor = 0.4
		particleSize = 1.0
		particleIntensity = 1
		particleMass = 1
		particleBounce = 0.7
		emissionDuration = 1

//		blendMode = .alpha
//		particleImage = Asset.sprite.image
//		imageSequenceRowCount = 4
//		imageSequenceColumnCount = 4
//		imageSequenceFrameRate = 0
//		imageSequenceInitialFrame = 16
//		imageSequenceInitialFrameVariation = 16
	}
	
	required init?(coder: NSCoder) { fatalError("") }
}


public final class GlobeView: SCNView {
	
	// MARK: - Properties
	
	enum CameraPosition {
		case revealed
	}
	
	struct Constants {
		static let revealAnimationDuration = 2 as CFTimeInterval
	}
	
	// MARK: - Private Properties
	
	private let cameraNode = SCNNode()
	
	// MARK: - Lifecycle
	
	override init(frame: CGRect) {
		
		super.init(frame: frame, options: [:])
		
		scene = SCNScene()
		
		cameraNode.position = .init(0, 4, 0)
		cameraNode.camera = .init()
		scene?.rootNode.addChildNode(cameraNode)
		
		let particles = StarParticles()
		scene?.rootNode.addParticleSystem(particles)
		
		backgroundColor = .clear
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) { fatalError() }
	
	// MARK: - Elements Manipulation
	
	func setCameraPosition(_ newValue: CameraPosition, animated: Bool = true) {
		let animation = CABasicAnimation(keyPath: "position")
		animation.fromValue = cameraNode.position
		
		let position: SCNVector3
		
		switch newValue {
		case .revealed:
			position = SCNVector3(0, -37, 40)
		}
		
		animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
		
		animation.toValue = position
		animation.duration = animated ? Constants.revealAnimationDuration : 0
		
		cameraNode.position = position
		cameraNode.addAnimation(animation, forKey: "position")
	}
	
}
