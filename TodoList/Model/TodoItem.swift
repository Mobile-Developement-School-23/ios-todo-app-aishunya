
import Foundation

struct TodoItem{
    
    let text: String
    let id: String
    let importance: Importance
    let deadline: Date?
    let done: Bool
    let creationDate: Date
    let changedDate: Date?
    
    init(text: String, id: String = UUID().uuidString, importance: Importance, deadline: Date? = nil, done: Bool, creationDate: Date = Date(), changedDate: Date? = nil) {
        self.text = text
        self.id = id
        self.importance = importance
        self.deadline = deadline
        self.done = done
        self.creationDate = creationDate
        self.changedDate = changedDate
    }
}

enum Importance: String {
    case important
    case regular
    case unimportant
}

//MARK: - JSON

extension TodoItem {
    
    static func parse(json: Any) -> TodoItem? {
        
        if let data = "\(json)".data(using: .utf8) {
                do {
                    if let todoItem = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        let text = todoItem["text"] as! String
                        let id = todoItem["id"] as! String
                        var importance = Importance.regular
                        if todoItem["importance"] != nil {
                            importance = Importance(rawValue: todoItem["importance"] as! String)!
                        }
                        var deadline: Date? = nil
                        var changedDate: Date? = nil
                        var creationDate: Date? = nil
                        if (todoItem["deadline"] != nil) {
                            deadline = Date(timeIntervalSince1970: todoItem["deadline"] as! TimeInterval)
                        }
                        let done = todoItem["done"] as! Bool
                        if todoItem["creationDate"] != nil {
                            creationDate = Date(timeIntervalSince1970: todoItem["creationDate"] as! TimeInterval)
                        }
                        if todoItem["changedDate"] != nil {
                            changedDate = Date(timeIntervalSince1970: todoItem["changedDate"] as! TimeInterval)
                        }
                        return TodoItem(text: text, id: id, importance: importance, deadline: deadline, done: done, creationDate: creationDate!, changedDate: changedDate)
                    } else {
                        print("failure")
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        return nil
    }
    
    var json: Any {
        var convertedTodoItem = ""
        var todoItem = [String:Any]()
        todoItem["text"] = text
        todoItem["id"] = id
        if importance != Importance.regular {
            todoItem["importance"] = importance.rawValue
        }
        if (deadline != nil) {
            todoItem["deadline"] = deadline!.timeIntervalSince1970
        }
        todoItem["done"] = done
        todoItem["creationDate"] = creationDate.timeIntervalSince1970
        if (changedDate != nil) {
            todoItem["changedDate"] = changedDate!.timeIntervalSince1970
            
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: todoItem, options: .prettyPrinted)
            convertedTodoItem = String(data: jsonData, encoding: .utf8)!
        } catch {
            print("Error encoding struct to JSON: \(error)")
        }
        return convertedTodoItem
    }
}

//MARK: - CSV

extension TodoItem {
    
    
    static func parse(csv: String) -> TodoItem? {
        let fields = csv.components(separatedBy: ",")
        let text = fields[0]
        let id = fields[1]
        
        let importance: Importance
        if fields[2] == "," || fields[2] == "" {
            importance = Importance.regular
        } else {
            print(fields[2])
            importance = Importance(rawValue: fields[2])!
        }
    
        let deadline: Date? = fields[3].isEmpty ? nil : Date(timeIntervalSince1970: Double(fields[3])!)
        let done = fields[4] == "true"
        let creationDate = Date(timeIntervalSince1970: Double(fields[5])!)
        let changedDate: Date? = fields[6].isEmpty ? nil : Date(timeIntervalSince1970: Double(fields[6])!)
        return TodoItem(text: text, id: id, importance: importance, deadline: deadline, done: done, creationDate: creationDate, changedDate: changedDate ?? nil)
    }

    var csv: String {
        var csvString = ""
        
        csvString += "\(text),"
        csvString += "\(id),"
        if importance.rawValue != "regular" {
            csvString += "\(importance.rawValue),"
        } else {
            csvString += ","
        }
        csvString += "\(deadline != nil ? String(deadline!.timeIntervalSince1970) : ""),"
        csvString += "\(String(done)),"
        csvString += "\(String(creationDate.timeIntervalSince1970)),"
        csvString += "\(changedDate != nil ? String(changedDate!.timeIntervalSince1970) : "")"
        
        return csvString
    }
}


