import UIKit
import PlaygroundSupport
import RxSwift
import RxCocoa

//: リスト 1-2 FRP を使った航空券予約サンプル（airline1.java）

class ViewController : UIViewController {

    let disposeBag = DisposeBag()

    override func loadView() {

        // Create views

        let view = UIView()
        view.backgroundColor = .white
        self.view = view

        let depLabel = UILabel()
        depLabel.text = "departure"
        view.addSubview(depLabel)

        let depPicker = UIDatePicker()
        depPicker.datePickerMode = .date

        let depTextField = UITextField()
        depTextField.borderStyle = .roundedRect
        depTextField.inputView = depPicker
        view.addSubview(depTextField)

        let retLabel = UILabel()
        retLabel.text = "return"
        view.addSubview(retLabel)

        let retPicker = UIDatePicker()
        retPicker.datePickerMode = .date

        let retTextField = UITextField()
        retTextField.borderStyle = .roundedRect
        retTextField.inputView = retPicker
        view.addSubview(retTextField)

        let ok = UIButton(type: .system)
        ok.setTitle("OK", for: .normal)
        view.addSubview(ok)

        // Layout views

        let margins = view.layoutMarginsGuide

        depLabel.translatesAutoresizingMaskIntoConstraints = false
        depLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        depLabel.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        depLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true

        depTextField.translatesAutoresizingMaskIntoConstraints = false
        depTextField.leadingAnchor.constraint(equalTo: depLabel.trailingAnchor).isActive = true
        depTextField.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        depTextField.centerYAnchor.constraint(equalTo: depLabel.centerYAnchor).isActive = true
        depTextField.heightAnchor.constraint(equalToConstant: 20).isActive = true

        retLabel.translatesAutoresizingMaskIntoConstraints = false
        retLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        retLabel.topAnchor.constraint(equalTo: depLabel.bottomAnchor).isActive = true
        retLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true

        retTextField.translatesAutoresizingMaskIntoConstraints = false
        retTextField.leadingAnchor.constraint(equalTo: retLabel.trailingAnchor).isActive = true
        retTextField.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        retTextField.centerYAnchor.constraint(equalTo: retLabel.centerYAnchor).isActive = true
        retTextField.heightAnchor.constraint(equalToConstant: 20).isActive = true

        ok.translatesAutoresizingMaskIntoConstraints = false
        ok.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        ok.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        ok.topAnchor.constraint(equalTo: retLabel.bottomAnchor).isActive = true
        ok.heightAnchor.constraint(equalToConstant: 20).isActive = true

        // Binding

        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日"
            return formatter
        }()

        depPicker.rx.controlEvent(.valueChanged)
            .map { _ in formatter.string(from: depPicker.date) }
            .bind(to: depTextField.rx.text)
            .disposed(by: disposeBag)

        retPicker.rx.controlEvent(.valueChanged)
            .map { _ in formatter.string(from: retPicker.date) }
            .bind(to: retTextField.rx.text)
            .disposed(by: disposeBag)

        let dep = depTextField.rx.text.map { text in formatter.date(from: text ?? "") }
        let ret = retTextField.rx.text.map { text in formatter.date(from: text ?? "") }
        let valid = Observable.combineLatest(dep, ret) { d, r -> Bool in
            guard let d = d, let r = r else { return false }
            return d <= r
        }
        .startWith(false)

        valid.bind(to: ok.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

PlaygroundPage.current.liveView = ViewController()
