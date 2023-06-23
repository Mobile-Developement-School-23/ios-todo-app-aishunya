

import UIKit

final class ItemImportanceView: UIStackView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private lazy var importanceLabel = getImportanceLabel()
    private lazy var segmentedControl = getSegmentedControl()
    
    private func getImportanceLabel() -> UILabel {
        let importanceLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 79, height: 22))
        importanceLabel.text = K.Strings.importance
        importanceLabel.textColor = K.Colors.labelPrimary
        importanceLabel.font = UIFont(name: K.Fonts.SFProText,size: 17.0)
        return importanceLabel
    }

    private func getSegmentedControl() -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: [UIImage(named: "arrowDown")!,"нет",UIImage(named: "important")!])
        segmentedControl.frame = CGRect(x: 0, y: 0, width: 150, height: 36)
        segmentedControl.selectedSegmentIndex = 2
        segmentedControl.tintColor = K.Colors.backElevated
        segmentedControl.backgroundColor = K.Colors.overlay
        segmentedControl.widthAnchor.constraint(equalToConstant: 150).isActive = true
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }
    
    private func setup() {
        axis = .horizontal
        backgroundColor = .clear
        alignment = .center
        translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(importanceLabel)
        addArrangedSubview(segmentedControl)
        
        }
}
