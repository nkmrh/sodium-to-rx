import UIKit
import PlaygroundSupport
import RxSwift
import RxCocoa

//: 2.8 snapshot プリミティブ：セルの値を取得する

class ViewController : UIViewController {

    let disposeBag = DisposeBag()

    override func loadView() {

        // Create views

        let view = UIView()
        view.backgroundColor = .white
        self.view = view

        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.text = "I like FRP"
        view.addSubview(textField)

        let button = UIButton(type: .system)
        button.setTitle("Translate", for: .normal)
        view.addSubview(button)

        let label = UILabel()
        label.textAlignment = .center
        view.addSubview(label)

        // Layout views

        let margins = view.layoutMarginsGuide

        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true

        button.translatesAutoresizingMaskIntoConstraints = false
        button.bottomAnchor.constraint(equalTo: label.topAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.bottomAnchor.constraint(equalTo: button.topAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 20).isActive = true

        // Use snapshot

        let sLatin = button.rx.tap.withLatestFrom(textField.rx.text) { _, text in
            return text?
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: " |$", with: "us ", options: .regularExpression)
                .trimmingCharacters(in: .whitespaces)
        }
        let latin = BehaviorSubject<String?>(value: "")
        sLatin
            .bind(to: latin)
            .disposed(by: disposeBag)
        latin
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
}

PlaygroundPage.current.liveView = ViewController()
