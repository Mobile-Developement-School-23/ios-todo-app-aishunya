
import UIKit

final class ItemSeparatorView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = K.Colors.separator
        heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    
}
