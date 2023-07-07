

import UIKit

final class ItemCalendarView: UICalendarView, UICalendarViewDelegate {
    
    private var deadline: Date?
    
    var setDeadline: ((Date) -> ())?
    
    var dateLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        availableDateRange = DateInterval(start: .now, end: Date.distantFuture)
        let selection = UICalendarSelectionSingleDate(delegate: self)
        selectionBehavior = selection
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func getDeadlineDate() -> Date? {
        return deadline
    }
    func setDeadlineDate(newDate: Date) {
        deadline = newDate
    }

    func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func hideCalendar() {
        UIView.animate(withDuration: TimeInterval(0.5)) {
            self.isHidden = true
        }
    }
    
    private func setup(){
        locale = .current
        fontDesign = .default
        translatesAutoresizingMaskIntoConstraints = false
        delegate = self
    }
}

extension ItemCalendarView: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        deadline = dateComponents?.date
        dateLabel?.text = dateToString(date: deadline!)
        setDeadline!(deadline!)
    }
}
