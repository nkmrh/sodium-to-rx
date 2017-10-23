import UIKit
import PlaygroundSupport
import RxSwift
import RxCocoa

//: 2.7 hold プリミティブ：状態をセルに保存する

class ViewController : UIViewController {

    let disposeBag = DisposeBag()

    override func loadView() {

        // Create views

        let view = UIView()
        view.backgroundColor = .white
        self.view = view

        let red = UIButton(type: .system)
        red.setTitle("red", for: .normal)
        view.addSubview(red)

        let green = UIButton(type: .system)
        green.setTitle("green", for: .normal)
        view.addSubview(green)

        let label = UILabel()
        label.textAlignment = .center
        view.addSubview(label)

        // Layout views

        let margins = view.layoutMarginsGuide

        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true

        green.translatesAutoresizingMaskIntoConstraints = false
        green.bottomAnchor.constraint(equalTo: label.topAnchor).isActive = true
        green.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        green.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        green.heightAnchor.constraint(equalToConstant: 20).isActive = true

        red.translatesAutoresizingMaskIntoConstraints = false
        red.bottomAnchor.constraint(equalTo: green.topAnchor).isActive = true
        red.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        red.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        red.heightAnchor.constraint(equalToConstant: 20).isActive = true

        // Merge streams

        let sRed = red.rx.tap.map { _ in "red" }
        let sGreen = green.rx.tap.map { _ in "green" }
        let sColor = Observable.of(sRed, sGreen).merge()
        let color = BehaviorSubject<String>(value: "")
        sColor
            .bind(to: color)
            .disposed(by: disposeBag)
        color
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
}

PlaygroundPage.current.liveView = ViewController()
