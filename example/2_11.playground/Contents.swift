import UIKit
import PlaygroundSupport
import RxSwift
import RxCocoa

//: 2.11 lift プリミティブ：セルを結合する

class ViewController : UIViewController {

    let disposeBag = DisposeBag()

    override func loadView() {

        // Create views

        let view = UIView()
        view.backgroundColor = .white
        self.view = view

        let txtA = UITextField()
        txtA.borderStyle = .roundedRect
        view.addSubview(txtA)

        let txtB = UITextField()
        txtB.borderStyle = .roundedRect
        view.addSubview(txtB)

        let label = UILabel()
        label.textAlignment = .center
        view.addSubview(label)

        // Layout views

        let margins = view.layoutMarginsGuide

        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true

        txtA.translatesAutoresizingMaskIntoConstraints = false
        txtA.bottomAnchor.constraint(equalTo: label.topAnchor).isActive = true
        txtA.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        txtA.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        txtA.heightAnchor.constraint(equalToConstant: 50).isActive = true

        txtB.translatesAutoresizingMaskIntoConstraints = false
        txtB.bottomAnchor.constraint(equalTo: txtA.topAnchor).isActive = true
        txtB.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        txtB.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        txtB.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let a = txtA.rx.text.flatMap { $0.flatMap { Observable.just($0) } ?? .empty() }
        let b = txtB.rx.text.flatMap { $0.flatMap { Observable.just($0) } ?? .empty() }
        let sum = Observable.combineLatest(a, b) { a, b in (Int(a) ?? 0) + (Int(b) ?? 0) }.map { $0.description }

        sum
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
}

let viewController = ViewController()
let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 640, height: 1600))
window.rootViewController = viewController
window.makeKeyAndVisible()

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = window

