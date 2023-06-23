

import UIKit

final class ItemDeadlineView: UIStackView {
    
    private lazy var deadlineLabel = getDeadlineLabel()
    private lazy var switchControl = getSwitchContol()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func getDeadlineLabel() -> UILabel {
        let deadlineLabel = UILabel()
        deadlineLabel.text = K.Strings.deadline
        deadlineLabel.textColor = K.Colors.labelPrimary
        deadlineLabel.font = UIFont(name: K.Fonts.SFProText,size: 17.0)
        deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        return deadlineLabel
    }

    private func getSwitchContol() -> UISwitch {
        let switchControl = UISwitch()
        switchControl.isOn = false
        switchControl.isEnabled = true
        switchControl.onTintColor = K.Colors.green
        switchControl.thumbTintColor = K.Colors.backSecondary
        switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        return switchControl
    }
    
    private func setup() {
        addArrangedSubview(deadlineLabel)
        addArrangedSubview(switchControl)
        axis = .horizontal
        alignment = .center
        spacing = 16
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
    }
    
}

//MARK: - Including Deadline (Switch On)

extension ItemDeadlineView {

    private var dateButton: UIButton {
        return getDateButton()
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
            if sender.isOn {
                var deadlineDateStack: UIStackView {
                    return getDeadlineDateStack()
                }
                removeSubviews(from: self)
                addArrangedSubview(deadlineDateStack)
                addArrangedSubview(switchControl)
            } else {
                removeSubviews(from: self)
                setup()
            }
        }
    
    private func getDateButton() -> UIButton {
        let dateButton = UIButton(frame: CGRect(x: 0, y: 0, width: 248, height: 18))
        dateButton.backgroundColor = .clear
        let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 13)
                ]
        let attributedTitle = NSAttributedString(string: "23 июня 2023", attributes: attributes)
        dateButton.setAttributedTitle(attributedTitle, for: .normal)
        dateButton.titleLabel?.textColor = K.Colors.blue
        dateButton.titleLabel?.textAlignment = .left
        dateButton.translatesAutoresizingMaskIntoConstraints = false
        dateButton.isUserInteractionEnabled = true
        dateButton.addTarget(self, action: #selector(dateButtonPressed), for: .touchUpInside)
        return dateButton
    }
    
    private func getDeadlineDateStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.backgroundColor = .clear
        stack.alignment = .leading
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(deadlineLabel)
        stack.addArrangedSubview(dateButton)
        return stack
    }
    
    private func removeSubviews(from stackView: UIStackView) {
        for arrangedSubview in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }
    }
    
    @objc func dateButtonPressed() {
        
    }
}

