import QuartzCore

public func clip<T : Comparable>(_ x0: T, _ x1: T, _ v: T) -> T {
	return max(x0, min(x1, v))
}

public func lerp<T : FloatingPoint>(_ v0: T, _ v1: T, _ t: T) -> T {
	return v0 + (v1 - v0) * t
}


public func -(lhs: CGPoint, rhs: CGPoint) -> CGVector {
	return CGVector(dx: lhs.x - rhs.x, dy: lhs.y - rhs.y)
}

public func -(lhs: CGPoint, rhs: CGVector) -> CGPoint {
	return CGPoint(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy)
}

public func -(lhs: CGVector, rhs: CGVector) -> CGVector {
	return CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
}

public func +(lhs: CGPoint, rhs: CGPoint) -> CGVector {
	return CGVector(dx: lhs.x + rhs.x, dy: lhs.y + rhs.y)
}

public func +(lhs: CGPoint, rhs: CGVector) -> CGPoint {
	return CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
}

public func +(lhs: CGVector, rhs: CGVector) -> CGVector {
	return CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
}

public func *(left: CGVector, right:CGFloat) -> CGVector {
	return CGVector(dx: left.dx * right, dy: left.dy * right)
}

public extension CGPoint {
	var vector: CGVector {
		return CGVector(dx: x, dy: y)
	}
}

public extension CGVector {
	var magnitude: CGFloat {
		return sqrt(dx*dx + dy*dy)
	}
	
	var point: CGPoint {
		return CGPoint(x: dx, y: dy)
	}
	
	func apply(transform t: CGAffineTransform) -> CGVector {
		return point.applying(t).vector
	}
}
