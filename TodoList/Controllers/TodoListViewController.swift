

import UIKit

class TodoListViewController: UIViewController {
    
    private let cellIdentifier = "cellIdentifier"
    private let floatingButton = FloatingButton()
    private let tableView = ContentSizedTableView()
    private var items = [TodoItem]()
    private var fileCache = AppDelegate.shared().fileCache
    private lazy var doneCountLabel = getDoneCountLabel()
    private lazy var toggleShowDoneItemsButton = getToggleShowDoneItemsButton()
    private lazy var headerStack = getHeaderStack()
    private var itemsToShow = [TodoItem]()
    private var isShowingAllItems = true
    private var completedItemsCount = 0
    
    private func setupItemsToShow() {
        if isShowingAllItems {
            itemsToShow = fileCache.items
        } else {
            itemsToShow = fileCache.items.filter{ $0.done == false}
        }
    }
    
    private func setupCompletedItemsCount() {
        let completed = fileCache.items.filter { $0.done == true }.count
        completedItemsCount = completed
        doneCountLabel.text = "Выполнено – \(completedItemsCount)"
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = K.Colors.backPrimary
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = K.Strings.mainTitle
        
        tableView.register(TodoListCell.self, forCellReuseIdentifier: cellIdentifier)
        
        floatingButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        setupTableView()
        view.addSubview(headerStack)
        view.addSubview(tableView)
        view.addSubview(floatingButton)
        view.bringSubviewToFront(floatingButton)
        setConstraints()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupItemsToShow()
        setupCompletedItemsCount()
    }
    
    private func getDoneCountLabel() -> UILabel {
        let label = UILabel()
        label.textColor = K.Colors.labelTertiary
        return label
    }
    
    private func getToggleShowDoneItemsButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Скрыть", for: .normal)
        button.setTitleColor(K.Colors.blue, for: .normal)
        button.addTarget(self, action: #selector(toggleShowAllItems), for: .touchUpInside)
        return button
    }
    
    @objc func toggleShowAllItems() {
        isShowingAllItems = !isShowingAllItems
        if toggleShowDoneItemsButton.currentTitle == "Показать" {
            toggleShowDoneItemsButton.setTitle("Скрыть", for: .normal)
        } else {
            toggleShowDoneItemsButton.setTitle("Показать", for: .normal)
        }
        itemsChanged()
    }
    
    
    
    private func getHeaderStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        
        stack.addArrangedSubview(doneCountLabel)
        stack.addArrangedSubview(toggleShowDoneItemsButton)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    
    @objc func addButtonTapped() {
        let secondVC = ItemViewController()
        secondVC.delegate =  self
        let presentedVC = UINavigationController(rootViewController: secondVC)
        presentedVC.modalPresentationStyle = .automatic
        present(presentedVC, animated: true)
    }
    
    @objc
    private func presentDetailsVC(at index: Int) {
        let item = itemsToShow[index]
        let itemDetailsVC = ItemViewController(item: item)
        itemDetailsVC.delegate = self
        let presentedVC = UINavigationController(rootViewController: itemDetailsVC)
        presentedVC.modalPresentationStyle = .automatic
        present(presentedVC, animated: true)
    }
    
    private func setupTableView() {
        tableView.backgroundColor = K.Colors.backSecondary
        tableView.layer.cornerRadius = 16
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func presentItemVC(_ todoItem: TodoItem?) {
        let itemVC = ItemViewController()
        itemVC.todoItem = todoItem
        itemVC.delegate = self
        let presentedVC = UINavigationController(rootViewController: itemVC)
        presentedVC.modalPresentationStyle = .automatic
        present(presentedVC, animated: true)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate(
            [
                tableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 7),
                tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                tableView.widthAnchor.constraint(equalToConstant: 343)
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
        NSLayoutConstraint.activate(
            [
                headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
                headerStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
                headerStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
                toggleShowDoneItemsButton.trailingAnchor.constraint(equalTo: headerStack.trailingAnchor)
            ]
        )
        
    }
    
    private func delete(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) {[weak self] (_, _, completion) in
            guard let self = self else {return}
            let item = itemsToShow[indexPath.row]
            itemsToShow.remove(at: indexPath.row)
            self.fileCache.deleteItem(id: item.id)
            self.fileCache.saveToFile(name: "test2")
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            itemsChanged()
            completion(true)
        }
        deleteAction.backgroundColor = K.Colors.red
        deleteAction.image = UIImage(systemName: "trash")
        return deleteAction
    }

    private func edit(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let editAction = UIContextualAction(style: .destructive, title: nil) {[weak self] (_, _, completion) in
            guard let self = self else {return}
            self.presentDetailsVC(at: indexPath.row)
            completion(true)
        }
        editAction.backgroundColor = K.Colors.grayLight
        editAction.image = UIImage(systemName: "info.circle.fill")
        return editAction
    }

    private func complete(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let completeAction = UIContextualAction(style: .destructive, title: nil) {[weak self] (_, _, completion) in
            guard let self = self else {return}
            let item = itemsToShow[indexPath.row]
            itemsToShow.remove(at: indexPath.row)
            self.fileCache.toggleDone(id: item.id)
            self.fileCache.saveToFile(name: "test2")
            tableView.deleteRows(at: [indexPath], with: .automatic)
            itemsChanged()
            completion(true)
        }
        completeAction.backgroundColor = K.Colors.green
        completeAction.image = UIImage(systemName: "checkmark.circle.fill")
        return completeAction
    }
    

}


//MARK: - TableView Configure

extension TodoListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(fileCache.items)
        return itemsToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TodoListCell
        cell.item = itemsToShow[indexPath.row]
        cell.onToggleItemDone = itemsChanged
        return cell
    }
}

extension TodoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentItemVC(itemsToShow[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = complete(rowIndexPathAt: indexPath)
        return UISwipeActionsConfiguration(actions: [completeAction])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = delete(rowIndexPathAt: indexPath)
        let editAction = edit(rowIndexPathAt: indexPath)
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

}

extension TodoListViewController: ItemViewControllerDelegate {
    func itemsChanged() {
        setupItemsToShow()
        setupCompletedItemsCount()
        tableView.reloadData()
    }
}
