

import UIKit

final class ItemDetailsStackView: UIStackView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        axis = .vertical
        layer.cornerRadius = 16
        backgroundColor = K.Colors.backSecondary
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 8, trailing: 14)
        spacing = 10
        translatesAutoresizingMaskIntoConstraints = false
    }
}
