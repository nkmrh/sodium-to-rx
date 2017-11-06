import UIKit
import PlaygroundSupport
import RxSwift
import RxCocoa

//: 2.10 filter プリミティブ：イベントを随時伝搬させる

class ViewController : UIViewController {

    let disposeBag = DisposeBag()

    override func loadView() {

        // Create views

        let view = UIView()
        view.backgroundColor = .white
        self.view = view

        let plus = UIButton(type: .system)
        plus.setTitle("+", for: .normal)
        view.addSubview(plus)

        let minus = UIButton(type: .system)
        minus.setTitle("-", for: .normal)
        view.addSubview(minus)

        let label = UILabel()
        label.textAlignment = .center
        view.addSubview(label)

        // Layout views

        let margins = view.layoutMarginsGuide

        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true

        plus.translatesAutoresizingMaskIntoConstraints = false
        plus.bottomAnchor.constraint(equalTo: label.topAnchor).isActive = true
        plus.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        plus.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        plus.widthAnchor.constraint(equalToConstant: 50).isActive = true
        plus.heightAnchor.constraint(equalToConstant: 50).isActive = true

        minus.translatesAutoresizingMaskIntoConstraints = false
        minus.bottomAnchor.constraint(equalTo: plus.topAnchor).isActive = true
        minus.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        minus.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        minus.widthAnchor.constraint(equalToConstant: 50).isActive = true
        minus.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let value = BehaviorSubject<Int>(value: 0)
        value
            .map { $0.description }
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)

        let sPlusDelta = plus.rx.tap.map { _ in 1 }
        let sMinusDelta = minus.rx.tap.map { _ in -1 }
        let sDelta = Observable.of(sPlusDelta, sMinusDelta).merge()
        let sUpdate = sDelta.withLatestFrom(value) { d, v in d + v }.filter { $0 >= 0 }

        sUpdate.bind(to: value)
    }
}

PlaygroundPage.current.liveView = ViewController()

