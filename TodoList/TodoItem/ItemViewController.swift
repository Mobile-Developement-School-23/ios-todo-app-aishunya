
import UIKit

final class ItemViewController: UIViewController, UICalendarViewDelegate, UITextViewDelegate {

    private lazy var navigationBar = setNavigationBar()
    private let scrollView = ItemScrollView()
    private let textView = ItemTextView()
    private let importanceView = ItemImportanceView()
    private let separator = ItemSeparatorView()
    private let deadlineView = ItemDeadlineView()
    private let deleteButton = ItemDeleteButton(type: .roundedRect)
    private var detailsStack = ItemDetailsStackView()
    private var calendarView = ItemCalendarView()
    private var calendarSeparator = ItemSeparatorView()
    private var fileCache = FileCache()
    private var todoItem: TodoItem?

    override func loadView() {
        
        super.loadView()
        detailsStack = ItemDetailsStackView(arrangedSubviews: [importanceView, separator, deadlineView, calendarSeparator, calendarView])
        calendarView.isHidden = true
        calendarSeparator.isHidden = true
        view.addSubview(scrollView)
        view.addSubview(navigationBar)
        
        scrollView.addToStackView(textView)
        scrollView.addToStackView(detailsStack)
        scrollView.addToStackView(deleteButton)
        
        setConstraints()
        
        deadlineView.delegate = self
        calendarView.delegate = self
        
        fileCache.loadFromFile(fileName: "test1")
        
        if !fileCache.dictionary.isEmpty {
            todoItem = Array(fileCache.dictionary.values)[0]
            textView.setText(newText: todoItem!.text)
            importanceView.setImportance(newImportance: todoItem!.importance)
            
            if todoItem?.deadline != nil {
                deadlineView.setSwitchOn()
                calendarView.setDeadlineDate(newDate: todoItem!.deadline!)
            }
        }
        
    }
    
    override func viewDidLoad() {
        textView.subscribeTextChanged { textNotEmpty in
            self.navigationBar.topItem?.rightBarButtonItem?.isEnabled = textNotEmpty
                }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapForHideKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapForHideKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(tapForHideKeyboard)
        super.viewDidLoad()
        setup()
        
        deleteButton.isUserInteractionEnabled = true
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
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
        
       
        saveButton.isEnabled = false
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
    

    
    //MARK: - Controls
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
        print("Cancelled")
    }
    
    @objc func saveButtonTapped() {
        print("Saved")
        saveItem()
    }
    
    @objc func deleteButtonTapped() {
        print("Delete")
        if todoItem != nil {
            fileCache.deleteItem(id: todoItem!.id)
            fileCache.saveToFile(name: "test1")
        }
    }
    
    func saveItem() {
        let text = textView.getText()
        let importance = importanceView.getImportance()
        var deadline: Date? = nil
        if deadlineView.isSwitchOn() {
            deadline = calendarView.getDeadlineDate()
        }
        
        let todoItem = TodoItem(text: text, importance: importance, deadline: deadline, done: false, creationDate: Date(), changedDate: Date())
        
        fileCache.addItem(item: todoItem)
        fileCache.saveToFile(name: todoItem.id)
        dismiss(animated: true)
    }
    
    @objc func dateButtonPressed() {
        
        // ДОСТАТЬ ДЕДЛАЙН
        
        if calendarView.isHidden == true {
            calendarView.isHidden = false
            calendarSeparator.isHidden = false
        } else {
            calendarView.isHidden = true
            calendarSeparator.isHidden = true
            
        }
    }
    
    //MARK: - Keyboard
    
    @objc private func hideKeyboard() {
            self.view.endEditing(true)
        }
    
    @objc func keyboardWillShow(_ notification: Notification) {
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }
            
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            
            let caretRect = textView.caretRect(for: textView.selectedTextRange?.end ?? textView.endOfDocument)
            scrollView.scrollRectToVisible(caretRect, animated: true)
        }
        
        @objc func keyboardWillHide(_ notification: Notification) {
            scrollView.contentInset = UIEdgeInsets.zero
            scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        }
        
        func textViewDidChange(_ textView: UITextView) {
            let caretRect = textView.caretRect(for: textView.selectedTextRange?.end ?? textView.endOfDocument)
            scrollView.scrollRectToVisible(caretRect, animated: true)
        }
    
}



