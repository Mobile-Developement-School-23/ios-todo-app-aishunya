

import UIKit

class TodoListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.Colors.backPrimary
        navigationItem.title = K.Strings.mainTitle
        let button = UIButton(frame: CGRect(x: 100, y: 150, width: 200, height: 40))
        view.addSubview(button)
        button.setTitle("To second VC", for: .normal)
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
    }
    
    @objc func buttonTapped() {
        let secondVC = ItemViewController()
        let presentedVC = UINavigationController(rootViewController: secondVC)
        presentedVC.modalPresentationStyle = .automatic
        present(presentedVC, animated: true)
    }
    

}
