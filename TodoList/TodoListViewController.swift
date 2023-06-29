

import UIKit

class TodoListViewController: UIViewController {
    
    private let cellId = "cellId"
    private var items = ["Купить сыр", "Сделать пиццу", "Задание"]
    private var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TodoListCell.self, forCellReuseIdentifier: cellId)
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1)
        setupTableView()
        view.addSubview(tableView)
    }
    
    
    private func setupTableView() {
        tableView.frame = CGRect(x: 16, y: 179, width: 343, height: 651)
        tableView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1)
        tableView.layer.cornerRadius = 16
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
//    private func setConstraints() {
//        NSLayoutConstraint.activate(
//            [
//                tableView.centerYAnchor.constraint(equalTo: c)
//            ]
//        )
//    }

}


extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TodoListCell
        
//        let item = items[indexPath.row]
//        cell.textLabel?.text = item
//
//        cell.accessoryView = UIImageView(image: UIImage(named: "chevron"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

