import Foundation
import RxSwift

class Trajectory {
    let time: Double
    let origin: CGPoint
    let period: Double
    let velocity: Vector

    init(time: Double, origin: CGPoint) {
        self.time = time
        self.origin = origin
        self.period = Double(arc4random() % 10) * 0.1 + 0.5
        let angle = Double(arc4random() % 10) * 0.1 * .pi * 2
        velocity = Vector(sin(angle), cos(angle)).mult(SimpleHomoSapiens.speed)
    }

    func position(at t: Double) -> CGPoint {
        return velocity.mult(t - time).add(origin)
    }
}

public final class SimpleHomoSapiens {

    static let speed = 80.0

    public init(id: Int,
                posInit: CGPoint,
                time: BehaviorSubject<Double>,
                sTick: Observable<UInt>) {
        let traj = BehaviorSubject<Trajectory>(value: Trajectory(time: try! time.value(), origin: posInit))
    }
}
