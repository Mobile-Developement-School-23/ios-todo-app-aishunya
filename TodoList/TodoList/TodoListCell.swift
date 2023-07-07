

import UIKit


final class TodoListCell: UITableViewCell {
    
    var fileCache = AppDelegate.shared().fileCache
    var onToggleItemDone: (() -> ())?
    private lazy var checkButton = getCheckButton()
    private lazy var itemTitle = getItemTitle()
    private lazy var deadlineLabel = getDeadlineLabel()
    private lazy var calendarImageView = UIImageView(image: UIImage(systemName: "calendar"))
    private lazy var deadlineStack = getDeadlineStack()
    private lazy var bodyStackView = getBodyStackView()
    private lazy var chevronButton = getChevronButton()
    private lazy var cellStackView = getCellStackView()
    private lazy var checkedImage = UIImage(named: "checked")
    private lazy var uncheckedImage = UIImage(named: "unchecked")
    private lazy var uncheckedRed = UIImage(named: "uncheckedRed")
    private lazy var importantSign = UIImage(named: "important")
    
    var item: TodoItem? {
        didSet {
            if item != nil {
                if item?.importance == .important {
                    checkButton.setImage(uncheckedRed, for: .normal)
                    let imageAttachment = NSTextAttachment()
                    imageAttachment.image = importantSign
                    let fullString = NSMutableAttributedString(string: "")
                    fullString.append(NSAttributedString(attachment: imageAttachment))
                    fullString.append(NSAttributedString(string:" \(item!.text)"))
                    itemTitle.attributedText = fullString
                }
                if item!.done {
                    checkButton.setImage(checkedImage, for: .normal)
                    let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: item!.text)
                    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
                    itemTitle.attributedText = attributeString
                    itemTitle.textColor = K.Colors.labelTertiary
                } else {
                    if item?.importance != .important {
                        itemTitle.attributedText = nil
                        itemTitle.text = item?.text
                    }
                    checkButton.setImage(uncheckedImage, for: .normal)
                    itemTitle.textColor = K.Colors.labelPrimary
                }
            }
            if item?.deadline != nil {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ru_RU")
                formatter.dateFormat = "dd MMMM"
                deadlineLabel.attributedText = NSAttributedString(string: formatter.string(from: (item?.deadline)!))
                calendarImageView.image = UIImage(systemName: "calendar")
            }
        }
     }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        print("INITED")
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        [
            checkButton, bodyStackView, chevronButton
        ].forEach{ cellStackView.addArrangedSubview($0) }
        contentView.addSubview(cellStackView)
        selectionStyle = .none
//        print("ADDED")
        setConstraints()
        
    }
    
    private func getCellStackView() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 12
        return stack
    }
    
    private func getCheckButton() -> UIButton {
        let button = UIButton()
        button.sizeThatFits(CGSize(width: 24, height: 24))
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        return button
    }
    
    @objc func checkButtonTapped() {
        fileCache.toggleDone(id: item!.id)
        onToggleItemDone!()
    }
    
    private func getBodyStackView() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [itemTitle, deadlineStack])
        stack.axis = .vertical
        return stack
    }
    
    private func getItemTitle() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 3
        label.textColor = .label
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }
    
    private func getDeadlineLabel() -> UILabel {
        let label = UILabel()
        label.text = ""
        label.textColor = .tertiaryLabel
        label.font = .systemFont(ofSize: 15)
        return label
    }
    
    private func getDeadlineStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        
        calendarImageView.tintColor = .tertiaryLabel
        stack.addArrangedSubview(calendarImageView)
        stack.addArrangedSubview(deadlineLabel)
        return stack
    }
    
    private func getChevronButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "chevron"), for: .normal)
        button.setImage(UIImage(named: "chevron"), for: .selected)
        button.addTarget(self, action: #selector(chevronButtonPressed), for: .touchUpInside)
        return button
    }
    
    @objc func chevronButtonPressed(at index: Int) {
        let vc = TodoListViewController()
        vc.presentItemVC(item)
    }
    
    @objc func deleteItem() {
        
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate(
            [
                cellStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                cellStackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
                cellStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
                cellStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                
                bodyStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                bodyStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                
                checkButton.widthAnchor.constraint(equalToConstant: 24),
                checkButton.heightAnchor.constraint(equalToConstant: 24),
                
                calendarImageView.widthAnchor.constraint(equalToConstant: 16),
                calendarImageView.heightAnchor.constraint(equalToConstant: 16),
                
                chevronButton.widthAnchor.constraint(equalToConstant: 24),
                chevronButton.heightAnchor.constraint(equalToConstant: 24)
            ]
        )
    }
}
