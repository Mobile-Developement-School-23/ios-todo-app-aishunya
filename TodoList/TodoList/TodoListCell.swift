

import UIKit

protocol TodoListCellDelegate {
    func deleteItem()
    func checkButtonPressed()
}

final class TodoListCell: UITableViewCell {
    
    private lazy var checkButton = getCheckButton()
    private lazy var calendarView = UIImageView(image: UIImage(named: "calendar"))
    private lazy var itemTitle = getItemTitle()
    private lazy var deadlineLabel = getDeadlineLabel()
    private lazy var deadlineStack = getDeadlineStack()
    private lazy var bodyStackView = getBodyStackView()
    private lazy var chevronButton = getChevronButton()
    private lazy var cellStackView = UIStackView(arrangedSubviews: [checkButton,bodyStackView, checkButton])
    
    var delegate: TodoListCellDelegate?
    
    var item: TodoItem? {
        didSet {
            itemTitle.text = item?.text
            deadlineLabel.text = item?.deadline?.formatted(date: .abbreviated, time: .omitted)
        }
     }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setup() {
        [
            checkButton,
            bodyStackView,
            chevronButton
        ].forEach { contentView.addSubview($0) }

        selectionStyle = .none
        addSubview(cellStackView)

    }
    
    private func getCheckButton() -> UIButton {
        let button = UIButton()
        button.sizeThatFits(CGSize(width: 24, height: 24))
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        button.layer.cornerRadius = 24
        button.setImage(UIImage(named: "checked"), for: .selected)
        return button
    }
    
    private func getBodyStackView() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [itemTitle, deadlineStack])
        stack.frame = CGRect(x: 0, y: 0, width: 242, height: 42)
        stack.backgroundColor = .yellow
        return stack
    }
    
    private func getVerticalStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }
    
    private func getItemTitle() -> UILabel {
        let label = UILabel()
        label.text = "Позвонить маме"
        label.textColor = .label
        label.font = .systemFont(ofSize: 17)
        return label
    }
    
    private func getDeadlineLabel() -> UILabel {
        let label = UILabel()
        label.text = "14 июня"
        label.textColor = .tertiaryLabel
        label.font = .systemFont(ofSize: 15)
        return label
    }
    
    private func getDeadlineStack() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [calendarView, deadlineLabel])
        return stack
    }
    
    private func getChevronButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "chevron"), for: .normal)
        button.setImage(UIImage(named: "chevron"), for: .selected)
        button.addTarget(self, action: #selector(chevronButtonPressed), for: .touchUpInside)
        return button
    }
    
    @objc func chevronButtonPressed() {
        
    }
    
    @objc func deleteItem() {
        
    }
}
