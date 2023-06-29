

import UIKit

final class ItemCalendarView: UICalendarView, UICalendarViewDelegate {
    
    private var deadline = Date()
    
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
    
    func getDeadlineDate() -> Date {
        return deadline
    }
    func setDeadlineDate(newDate: Date) {
        deadline = newDate
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
        deadline = dateComponents!.date!
    }
}

