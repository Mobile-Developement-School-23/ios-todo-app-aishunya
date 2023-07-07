

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
        self.init(type: .system)
        setup()
    }
    
    private func setup() {
        setImage(UIImage(named: "addButton"), for: .normal)
        frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 42
        layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.3
    }
}

