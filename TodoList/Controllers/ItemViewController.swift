
import UIKit

protocol ItemViewControllerDelegate: AnyObject {
    func itemsChanged()
    func removeItem(id: String)
    func addItem(item: TodoItem)
}

final class ItemViewController: UIViewController, UICalendarViewDelegate, UITextViewDelegate {

    private let scrollView = ItemScrollView()
    private let textView = ItemTextView()
    private let importanceView = ItemImportanceView()
    private let separator = ItemSeparatorView()
    private let deadlineView = ItemDeadlineView()
    private let deleteButton = ItemDeleteButton(type: .roundedRect)
    private var detailsStack = ItemDetailsStackView()
    private var calendarView = ItemCalendarView()
    private var calendarSeparator = ItemSeparatorView()
    
    var todoItem: TodoItem?
    var deadline: Date?
    weak var delegate: ItemViewControllerDelegate?
    
    init(item: TodoItem? = nil) {
        self.todoItem = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }
    

    override func loadView() {
        
        super.loadView()
        detailsStack = ItemDetailsStackView(arrangedSubviews: [importanceView, separator, deadlineView, calendarSeparator, calendarView])
        calendarView.isHidden = true
        calendarSeparator.isHidden = true
        view.addSubview(scrollView)
        calendarView.setDeadline = setDeadline
        
        scrollView.addToStackView(textView)
        scrollView.addToStackView(detailsStack)
        scrollView.addToStackView(deleteButton)
        
        setConstraints()
        
        deadlineView.delegate = self
        calendarView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        
        textView.subscribeTextChanged { isEnabled in
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem?.isEnabled = isEnabled
                }
        
        if todoItem != nil {
            let item = todoItem!
            textView.setText(newText: item.text)
            importanceView.setImportance(newImportance: item.importance)
            if item.deadline != nil {
                let deadline = item.deadline!
                deadlineView.setSwitchOn()
                deadlineView.deadline = deadline
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapForHideKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapForHideKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(tapForHideKeyboard)
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
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                scrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor)
            ]
        )
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
            delegate?.removeItem(id: todoItem!.id)
        }
    }
    
    func saveItem() {
        let text = textView.getText()
        let importance = importanceView.getImportance()
        
        var todoItem = TodoItem(text: text, importance: importance, deadline: deadline, done: false, creationDate: Date(), changedDate: Date())
        
        if self.todoItem != nil {
            todoItem.id = self.todoItem!.id
        }
        
        delegate?.addItem(item: todoItem)
        dismiss(animated: true)
    }
    
    func setDeadline(deadline: Date) {
        self.deadline = deadline
        deadlineView.deadline = deadline
    }
    
    @objc func dateButtonPressed(hideCalendar: Bool) {
        
        if calendarView.isHidden == true && !hideCalendar {
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


//MARK: - Navigation Bar Configure

extension ItemViewController {
    
    private func setNavigationBar()  {
        
        let cancelButton = UIBarButtonItem(title: K.Strings.cancel, style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton
        
        let saveButton = UIBarButtonItem(title: K.Strings.save, style: .plain, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveButton
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 17)
        ]
        saveButton.setTitleTextAttributes(attributes, for: .normal)
        saveButton.setTitleTextAttributes(attributes, for: .disabled)
        saveButton.setTitleTextAttributes(attributes, for: .highlighted)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.shadowColor = nil
        navigationBarAppearance.backgroundColor = nil
        
        saveButton.isEnabled = false
    }
    
}
