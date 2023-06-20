
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let todoItem = TodoItem(text: "delo", id: "12345", importance: .important, deadline: nil, done: false, creationDate: Date(), changedDate: nil)
        
        let fileCache = FileCache()
        
        fileCache.addItem(item: todoItem)
        fileCache.saveToFile(name: "sample")
        fileCache.loadFromFile(fileName: "sample")
        
        print(todoItem.json)
        print(fileCache.saveToCSV(name: "sample"))
        print(todoItem.csv)
    }


}

