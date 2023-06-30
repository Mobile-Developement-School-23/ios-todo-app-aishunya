

import UIKit

class FloatingButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init() {
        self.init(type: .custom)
        setup()
    }
    
    private func setup() {
        contentVerticalAlignment = .fill
        contentHorizontalAlignment = .fill
        setImage(UIImage(named: "addButton"), for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 42
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = .init(width: 0, height: 8)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.3
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
}

