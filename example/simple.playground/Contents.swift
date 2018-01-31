import UIKit
import PlaygroundSupport
import RxSwift
import RxCocoa

class ViewController : UIViewController {

    let disposeBag = DisposeBag()

    override func loadView() {
        let v = Vector(1, 1)
        let h = SimpleHomoSapiens()
    }
}

let viewController = ViewController()
let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 640, height: 1600))
window.rootViewController = viewController
window.makeKeyAndVisible()

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = window

