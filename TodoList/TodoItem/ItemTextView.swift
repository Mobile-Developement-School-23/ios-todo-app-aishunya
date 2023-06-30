


import UIKit

final class ItemTextView: UITextView {
    
    private var onTextChanged: ((Bool) -> ())?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    func getText() -> String {
        return text
    }
    
    func setText(newText: String) {
        text = newText
        textColor = K.Colors.labelPrimary
        
    }
    
    private lazy var placeholder = K.Strings.placeholder
    
    private func setup() {
        frame = CGRect(x: 0, y: 0, width: 343, height: 120)
        backgroundColor = K.Colors.backSecondary
        font = UIFont.systemFont(ofSize: 17)
        text = placeholder
        textColor = K.Colors.labelTertiary
        textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        heightAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
        translatesAutoresizingMaskIntoConstraints = false
        invalidateIntrinsicContentSize()
        layer.cornerRadius = 16
        isScrollEnabled = false
        delegate = self
    }
    
    func subscribeTextChanged(callback: @escaping (Bool) -> ()) {
            onTextChanged = callback
        }
    
}

extension ItemTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == K.Colors.labelTertiary && textView.text == placeholder {
            textView.text = ""
            textView.textColor = K.Colors.labelPrimary
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = K.Colors.labelTertiary
            text = textView.text
        }
        
        onTextChanged?(textView.text != placeholder)
    }
}
