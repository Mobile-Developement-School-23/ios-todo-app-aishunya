

import UIKit

final class ItemDeadlineView: UIStackView {
    
    private lazy var deadlineLabel = getDeadlineLabel()
    private lazy var switchControl = getSwitchContol()
    
    var delegate: ItemViewController?
    var deadline: Date? {
        didSet {
            guard let deadline else {
                return
            }
            
            deadlineLabel.text = dateFormatter.string(from: deadline)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "ru")
        return dateFormatter
    }
    
    func isSwitchOn() -> Bool {
        return switchControl.isOn
    }
    
    func setSwitchOn() {
        switchControl.setOn(true, animated: true)
    }
    
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
        switchControl.thumbTintColor = K.Colors.white
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

//MARK: - Including Date Button (Switch On)

extension ItemDeadlineView {

    private var dateButton: UIButton {
        return getDateButton()
    }
    
    private var deadlineDateStack: UIStackView {
        return getDeadlineDateStack()
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
            if sender.isOn {
                removeSubviews(from: self)
                addArrangedSubview(deadlineDateStack)
                addArrangedSubview(switchControl)
            } else {
                removeSubviews(from: self)
                setup()
                
            }
        }
    
    var deadlineLabelText: String {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
        return dateToString(date: tomorrow)
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func getDateButton() -> UIButton {
        let dateButton = UIButton(frame: CGRect(x: 0, y: 0, width: 248, height: 18))
        dateButton.backgroundColor = .clear
        let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 13)
                ]
        let attributedTitle = NSAttributedString(string: deadlineLabelText, attributes: attributes)
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
    
    @objc func dateButtonPressed(){
        delegate?.dateButtonPressed()
    }
}

//MARK: - Including CalendarView

extension ItemDeadlineView: UICalendarViewDelegate {
    
    private var calendarView: ItemCalendarView {
        return ItemCalendarView(frame: CGRect(x: 0, y: 0, width: 311, height: 312))
    }
    
    private func showCalendarView() {
        deadlineDateStack.addArrangedSubview(calendarView)
    }
}

