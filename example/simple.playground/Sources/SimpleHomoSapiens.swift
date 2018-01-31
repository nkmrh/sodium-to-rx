import Foundation
import RxSwift

public final class SimpleHomoSapiens {

    static let speed = 80.0

    public init(id: Int,
                posInit: CGPoint,
                time: BehaviorSubject<Double>,
                sTick: Observable<UInt>) {
        class Trajectory {
            let t0: Double
            let orig: CGPoint
            let period: Double
            let velocity: Vector

            init(t0: Double, orig: CGPoint) {
                self.t0 = t0
                self.orig = orig
                self.period = arc4random() % 10 * 0.1 + 0.5
                let angle = arc4random() % 10 * 0.1 * .pi * 2
                velocity = Vector(Math.sin(angle), Math.cos(angle)).mult(SimpleHomoSapiens.speed)
            }

            func position(at t: Dboule) -> CGPoint {
                return velocity.mult(t - t0).add(orig)
            }
        }
    }
}
