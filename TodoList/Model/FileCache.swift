
import Foundation

class FileCache {
    
    var dictionary = [String: TodoItem]()
    
    func addItem(item: TodoItem) {
        dictionary[item.id] = item
    }
    
    func deleteItem(id: String) {
        dictionary.removeValue(forKey: id)
    }
    
    func saveToFile(name: String) {
        let str = dictionary.values.reduce("") { partialResult, item in
            "\(partialResult)\n\n\(item.json)"
        }
        let filename = getDocumentsDirectory().appendingPathComponent(name)

        do {
            try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            
        }
        print("Succesfully saved TodoItem")
    }
    
    func loadFromFile(fileName: String) {
        let todoItems = getTextFromFile(fileName: fileName).split(separator: "\n\n")
        for i in 0..<todoItems.count {
            let todoItem = TodoItem.parse(json: todoItems[i])!
            dictionary[todoItem.id] = todoItem
        }
    }
    
    func saveToCSV(name: String) {
        var str = "Text,ID,Importance,Deadline,Done,Creation Date,Changed Date"
        str += dictionary.values.reduce("") { partialResult, item in
            "\(partialResult)\n\(item.csv)"
        }
        let filename = getDocumentsDirectory().appendingPathComponent("\(name).csv")

        do {
            try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            
        }
    }
    
    func loadFromCSV(fileName: String) {
        let todoItems = getTextFromFile(fileName: "\(fileName).csv").split(separator: "\n")
        for i in 1..<todoItems.count {
            let todoItem = TodoItem.parse(csv: String(todoItems[i]))!
            dictionary[todoItem.id] = todoItem
        }
    }
    
    func exists(id: String) -> Bool {
        return dictionary[id] != nil
    }
    
    func getDocumentsDirectory() -> URL {
        let fileManager = FileManager.default
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func getTextFromFile(fileName: String) -> String {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            do {
                return try String(contentsOf: fileURL, encoding: .utf8)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return ""
    }
    
}
