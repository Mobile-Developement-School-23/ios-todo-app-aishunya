


import UIKit

final class ItemTextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    private lazy var placeholder = K.Strings.placeholder
    
    private func setup() {
        invalidateIntrinsicContentSize()
        frame = CGRect(x: 0, y: 0, width: 343, height: 120)
        backgroundColor = K.Colors.backSecondary
        font = UIFont(name: K.Fonts.SFProText, size: 17.0)
        text = placeholder
        textColor = K.Colors.labelTertiary
        textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        heightAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        isScrollEnabled = false
        delegate = self
    }
    
}

extension ItemTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == K.Colors.labelTertiary && textView.text == placeholder {
            textView.text = ""
            textView.textColor = K.Colors.labelPrimary
            textView.font = UIFont(name: K.Fonts.SFProText, size: 17.0)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = K.Colors.labelTertiary
            textView.font = UIFont(name: K.Fonts.SFProText, size: 17.0)
        }
    }
}
