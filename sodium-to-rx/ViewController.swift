//
//  ViewController.swift
//  sodium-to-rx
//
//  Created by hajime-nakamura on 2017/10/20.
//  Copyright © 2017 hajime-nakamura. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

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


public final class SimpleHomoSapiens {

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

    static let speed = 80.0

    public init(id: Int,
                posInit: CGPoint,
                time: BehaviorSubject<Double>,
                sTick: Observable<Void>) {
        let traj = BehaviorSubject<Trajectory>(value: Trajectory(time: try! time.value(), origin: posInit))
        let sChange = sTick.withLatestFrom(traj) { u, traj_ -> Observable<Void> in
            return try! time.value() - traj_.time >= traj_.period
                ? .just(())
                : .empty()
        }
    }
}

