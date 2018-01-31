import UIKit

public final class Vector {
    public let dx, dy: Double

    public var magnitude: Double {
        return sqrt(dx * dx + dy * dy)
    }

    public var normalize: Vector {
        return mult(1 / magnitude)
    }

    public init(_ dx: Double, _ dy: Double) {
        self.dx = dx
        self.dy = dy
    }

    public func mult(_ c: Double) -> Vector {
        return Vector(dx * c, dy * c)
    }

    public func add(_ p: CGPoint) -> CGPoint {
        return CGPoint(x: CGFloat(dx) + p.x, y: CGFloat(dy) + p.y)
    }

    public static func subtract(_ a: CGPoint, _ b: CGPoint) -> Vector {
        return Vector(Double(a.x - b.x), Double(a.y - b.y))
    }

    public static func distance(_ a: CGPoint, _ b: CGPoint) -> Double {
        return Vector.subtract(a, b).magnitude
    }
}
