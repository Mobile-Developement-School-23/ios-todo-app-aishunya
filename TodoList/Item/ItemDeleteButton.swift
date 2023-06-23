
import UIKit

final class ItemDeleteButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = K.Colors.backSecondary
        layer.cornerRadius = 16
        titleLabel?.font = UIFont(name: K.Fonts.SFProText, size: 17)
        titleLabel?.textAlignment = .center
        setTitle(K.Strings.delete, for: .normal)
        setTitleColor(UIColor(named: "Label Tertiary"), for: .disabled)
        setTitleColor(K.Colors.red, for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
        isEnabled = false
    }
    
    private func setConstraints() {
        widthAnchor.constraint(equalToConstant: 343).isActive = true
        heightAnchor.constraint(equalToConstant: 56).isActive = true
    }
    
    
    
    
}
