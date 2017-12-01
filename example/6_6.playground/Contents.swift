import UIKit
import PlaygroundSupport
import RxSwift
import RxCocoa

PlaygroundPage.current.needsIndefiniteExecution = true

//: 6.6 例：FRP 方式の自動補完機能

class ViewController : UIViewController {

    let disposeBag = DisposeBag()

    override func loadView() {

        // Create views

        let view = UIView()
        view.backgroundColor = .white
        self.view = view

        let label = UILabel()
        label.text = "City"
        view.addSubview(label)

        let textField = UITextField()
        textField.borderStyle = .roundedRect
        view.addSubview(textField)

        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)

        // Layout views

        let margins = view.layoutMarginsGuide

        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: textField.leadingAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leadingAnchor.constraint(equalTo: label.trailingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        textField.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: textField.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: textField.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: textField.bottomAnchor).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        let sEntered = autocomplete(textEdit: textField, tableView: tableView)
        lookup(urlString: "http://getcitydetails.geobytes.com/GetCityDetails?fqcn=", keyword: sEntered)
            .subscribe(onNext: { cityInfo in
                print("----------------------------------------")
                print(cityInfo)
            })
            .disposed(by: disposeBag)
    }

    func currentTextOf(textField: UITextField) -> BehaviorSubject<String?> {
        let sKeyPresses = textField.rx.text
        let text = BehaviorSubject<String?>(value: textField.text)
        sKeyPresses.subscribe(text)
        return text
    }

    func lookup(urlString: String, keyword: Observable<String?>) -> Observable<[String]> {
        return .create { [weak self] observer -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            keyword
                .subscribe(onNext: { keyword in
                    guard let keyword = keyword else { return }
                    if let url = URL(string: urlString.appending(keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")) {
                        let task = URLSession.shared.dataTask(with: url) { data, response, error in
                            if let error = error {
                                observer.onError(error)
                            } else if let data = data {
                                if let suggestions = (try? JSONSerialization.jsonObject(with: data)) as? [String] {
                                    observer.onNext(suggestions)
                                } else if let suggestions = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] {
                                    print(suggestions)
//                                    observer.onNext(suggestions)
                                }
                            }
                        }
                        task.resume()
                    }
                })
                .disposed(by: strongSelf.disposeBag)
            return Disposables.create()
        }
    }

    func autocomplete(textEdit: UITextField, tableView: UITableView) -> Observable<String?> {
        let editText = currentTextOf(textField: textEdit)
        let sDebounced = editText.startWith(nil).debounce(0.1, scheduler: MainScheduler.instance)

        let sEnterKey = textEdit.rx.controlEvent([.editingDidEndOnExit]).map { _ in }
        let sClicked = tableView.rx.modelSelected(String?.self).map { $0 }
        let sClearPopUp = Observable.of(sClicked.map { _ in }, sEnterKey.map{ _ in }).merge()

        let lookedUp = Observable.of(sClearPopUp.map { _ in [String]() },
                                     lookup(urlString: "http://gd.geobytes.com/AutoCompleteCity?q=", keyword: sDebounced)
            .map { response in
                return (response.count == 1 && (response.first == "%s" || response.first == "")) ? [String]() : response
            }).merge()

//        lookedUp.bind(to: tableView.rx.items(cellIdentifier: "Cell")) { row, element, cell in
//            cell.textLabel?.text = element
//        }
//        .disposed(by: disposeBag)

        return Observable.of(sEnterKey.withLatestFrom(editText), sClicked).merge()
    }
}

let viewController = ViewController()
let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 768, height: 1024))
window.rootViewController = viewController
window.makeKeyAndVisible()

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = window
