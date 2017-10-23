import UIKit
import PlaygroundSupport
import RxSwift
import RxCocoa

//: 2.6 merge プリミティブ：ストリームをマージする

class ViewController : UIViewController {

    let disposeBag = DisposeBag()

    override func loadView() {

        // Create views

        let view = UIView()
        view.backgroundColor = .white
        self.view = view

        let onegai = UIButton(type: .system)
        onegai.setTitle("Onegai shimasu", for: .normal)
        view.addSubview(onegai)

        let thanks = UIButton(type: .system)
        thanks.setTitle("Thank you", for: .normal)
        view.addSubview(thanks)

        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        view.addSubview(textField)

        // Layout views

        let margins = view.layoutMarginsGuide

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        textField.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true

        thanks.translatesAutoresizingMaskIntoConstraints = false
        thanks.bottomAnchor.constraint(equalTo: textField.topAnchor).isActive = true
        thanks.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        thanks.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        thanks.heightAnchor.constraint(equalToConstant: 20).isActive = true

        onegai.translatesAutoresizingMaskIntoConstraints = false
        onegai.bottomAnchor.constraint(equalTo: thanks.topAnchor).isActive = true
        onegai.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        onegai.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        onegai.heightAnchor.constraint(equalToConstant: 20).isActive = true

        // Merge streams

        let sOnegai = onegai.rx.tap.map { _ in "Onegai shimasu" }
        let sThanks = thanks.rx.tap.map { _ in "Thank you" }
        let sCanned = Observable.of(sOnegai, sThanks).merge()
        sCanned
            .bind(to: textField.rx.text)
            .disposed(by: disposeBag)
    }
}

PlaygroundPage.current.liveView = ViewController()
