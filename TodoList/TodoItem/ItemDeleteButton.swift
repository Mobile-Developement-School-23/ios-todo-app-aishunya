
import UIKit

final class ItemDeleteButton: UIButton {
    
    override var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else {
                return
            }
            
            titleLabel!.textColor = isEnabled ? K.Colors.red : K.Colors.labelTertiary
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(type: .custom)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.font = UIFont(name: K.Fonts.SFProText, size: 17)
    }
    
    private func setup() {
        backgroundColor = K.Colors.backSecondary
        layer.cornerRadius = 16.0
        setTitle(K.Strings.delete, for: .disabled)
        setTitle(K.Strings.delete, for: .normal)
        titleLabel?.textAlignment = .center
        setTitleColor(K.Colors.labelTertiary, for: .disabled)
        setTitleColor(K.Colors.red, for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
    }
    
    private func setConstraints() {
        widthAnchor.constraint(equalToConstant: 343).isActive = true
        heightAnchor.constraint(equalToConstant: 56).isActive = true
    }
    
    
    
    
}
