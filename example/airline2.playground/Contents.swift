import UIKit
import PlaygroundSupport
import RxSwift
import RxCocoa

//: リスト 1-5 ビジネスルールのカプセル化（airline2.java）

class Rule {
    let f: (Date, Date) -> Bool

    init(f: @escaping (Date, Date) -> Bool) {
        self.f = f
    }

    func reify(dep: Observable<Date>, ret: Observable<Date>) -> Observable<Bool> {
        return Observable.combineLatest(dep, ret) { d, r in self.f(d, r) }
    }

    func and(other: Rule) -> Rule {
        return Rule { d, r -> Bool in self.f(d, r) && other.f(d, r) }
    }
}

//: リスト 1-6 抽象的なビジネスルールの操作 (airline2.java)

class ViewController : UIViewController {

    let disposeBag = DisposeBag()

    private static func unlucky(dt: Date) -> Bool {
        let calender = Calendar(identifier: .gregorian)
        let components = calender.dateComponents([Calendar.Component.day], from: dt)
        let day = components.day
        return day == 4 || day == 14 || day == 24
    }

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

        let dep = depPicker.rx.controlEvent(.valueChanged).map { depPicker.date }
        let ret = retPicker.rx.controlEvent(.valueChanged).map { retPicker.date }

        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日"
            return formatter
        }()

        dep
            .map { formatter.string(from: $0) }
            .bind(to: depTextField.rx.text)
            .disposed(by: disposeBag)

        ret
            .map { formatter.string(from: $0) }
            .bind(to: retTextField.rx.text)
            .disposed(by: disposeBag)

        // 復路の日付が往路の日付よりも前になることはあり得ない
        let r1 = Rule { d, r -> Bool in  d <= r }

        // 不吉な日には旅行できない
        let r2 = Rule { d, r -> Bool in !ViewController.unlucky(dt: d) && !ViewController.unlucky(dt: r) }

        let r = r1.and(other: r2)
        let valid = r.reify(dep: dep, ret: ret).startWith(false)
        valid.bind(to: ok.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

let viewController = ViewController()
let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 640, height: 1600))
window.rootViewController = viewController
window.makeKeyAndVisible()

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = window

