
import UIKit

final class ItemViewController: UIViewController, UITextViewDelegate {
    
    private lazy var navigationBar = setNavigationBar()
    private let scrollView = ItemScrollView()
    private let textView = ItemTextView()
    private let importanceView = ItemImportanceView()
    private let separator = ItemSeparatorView()
    private let deadlineView = ItemDeadlineView()
    private let deleteButton = ItemDeleteButton()
    private var detailsStack = ItemDetailsStackView()
    
    override func loadView() {
        detailsStack = ItemDetailsStackView(arrangedSubviews: [importanceView, separator, deadlineView])
        super.loadView()
        view.addSubview(scrollView)
        view.addSubview(navigationBar)
        scrollView.addToStackView(textView)
        scrollView.addToStackView(detailsStack)
        scrollView.addToStackView(deleteButton)
        setConstraints()
//        textView.delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        view.backgroundColor = K.Colors.backPrimary
    }

    
    private func setConstraints() {
        NSLayoutConstraint.activate(
            [
                scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                scrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor)
            ]
        )
    }
}

//MARK: - Navigation Bar Configure

extension ItemViewController {
    private func setNavigationBar() -> UINavigationBar {
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        let navigationItem = UINavigationItem(title: K.Strings.item)
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.shadowColor = nil
        navigationBarAppearance.backgroundColor = nil
        navigationBar.backgroundColor = nil
        navigationBar.barTintColor = K.Colors.backPrimary
        navigationBar.isTranslucent = true
        navigationBar.setValue(true, forKey: "hidesShadow")
        
        let cancelButton = UIBarButtonItem(title: K.Strings.cancel, style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton
        
        let saveButton = UIBarButtonItem(title: K.Strings.save, style: .plain, target: self, action: #selector(saveButtonTapped))
        let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 17)
                ]
        saveButton.setTitleTextAttributes(attributes, for: .normal)
        saveButton.setTitleTextAttributes(attributes, for: .disabled)
        saveButton.setTitleTextAttributes(attributes, for: .highlighted)
        
       
        saveButton.tintColor = K.Colors.labelDisable
        navigationItem.rightBarButtonItem = saveButton
        
        navigationBar.items = [navigationItem]
        view.addSubview(navigationBar)
        
        NSLayoutConstraint.activate([
                    navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
        
        return navigationBar
    }
    
    @objc func cancelButtonTapped() {
        print("Cancelled")
    }
    
    @objc func saveButtonTapped() {
        print("Saved")
    }
}
