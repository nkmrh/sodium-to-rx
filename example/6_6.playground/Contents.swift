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

        let s = Observable.just("tok")

        let suggestions = lookup(urlString: "http://gd.geobytes.com/AutoCompleteCity?q=", keyword: s).share(replay: 1)

        suggestions.bind(to: tableView.rx.items(cellIdentifier: "Cell")) { row, element, cell in
            cell.textLabel?.text = element
        }
        .disposed(by: disposeBag)

        tableView.rx.modelSelected(String.self)
            .subscribe(onNext: { suggestion in
                textField.text = suggestion
            })
            .disposed(by: disposeBag)
    }

    func lookup(urlString: String, keyword: Observable<String>) -> Observable<[String]> {
        return .create { [weak self] observer -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            keyword
                .subscribe(onNext: { keyword in
                    if let url = URL(string: urlString.appending(keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")) {
                        let task = URLSession.shared.dataTask(with: url) { data, response, error in
                            if let error = error {
                                observer.onError(error)
                            } else if let data = data,
                                let suggestions = (try? JSONSerialization.jsonObject(with: data)) as? [String] {
                                observer.onNext(suggestions)
                            }
                        }
                        task.resume()
                    }
                })
                .disposed(by: strongSelf.disposeBag)
            return Disposables.create()
        }
    }

    func autocomplete(textEdit: String) {

    }
}

let viewController = ViewController()
let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 640, height: 1600))
window.rootViewController = viewController
window.makeKeyAndVisible()

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = window
