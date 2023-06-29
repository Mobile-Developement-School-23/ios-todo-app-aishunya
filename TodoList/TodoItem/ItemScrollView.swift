
import UIKit

final class ItemScrollView: UIScrollView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private lazy var mainStackView = getMainStackView()
    
    private func getMainStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func setup() {
        isScrollEnabled = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        backgroundColor = .clear
        contentInsetAdjustmentBehavior = .always
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)
        
    }
    
    func addToStackView(_ subview: UIView){
        mainStackView.addArrangedSubview(subview)
    }
    
    private func setConstraints() {
            NSLayoutConstraint.activate([
                mainStackView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor, constant: 16),
                mainStackView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor, constant: -34),
                mainStackView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -16),
                mainStackView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 16)
            ])
        }
}


