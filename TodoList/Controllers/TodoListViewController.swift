

import UIKit

class TodoListViewController: UIViewController {
    
    private let cellIdentifier = "cellIdentifier"
    private var tableView = UITableView()
    private let floatingButton = FloatingButton()
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = K.Colors.backPrimary
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = K.Strings.mainTitle
        
        floatingButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        tableView.register(TodoListCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        view.addSubview(floatingButton)
        view.bringSubviewToFront(floatingButton)
        setupTableView()
        setConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @objc func buttonTapped() {
        let secondVC = ItemViewController()
        let presentedVC = UINavigationController(rootViewController: secondVC)
        presentedVC.modalPresentationStyle = .automatic
        present(presentedVC, animated: true)
    }
    
    private func setupTableView() {
        tableView.backgroundColor = K.Colors.backSecondary
        tableView.layer.cornerRadius = 16
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate(
            [
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 134),
                tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                tableView.widthAnchor.constraint(equalToConstant: 343),
                tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 224)
            ]
        )
        NSLayoutConstraint.activate(
            [
                floatingButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                floatingButton.widthAnchor.constraint(equalToConstant: 44),
                floatingButton.heightAnchor.constraint(equalToConstant: 44)
            ]
        )
        
    }
    

}


//MARK: - TableView Configure

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TodoListCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
