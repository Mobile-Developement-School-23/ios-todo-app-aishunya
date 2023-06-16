
import XCTest
@testable import TodoList

final class ToDoListTests: XCTestCase {


    func testExample() throws {
        let item = TodoItem(text: "Make a call", id: "12345", importance: .regular, deadline: Date(timeIntervalSince1970: 1623807600), done: false, creationDate: Date(), changedDate: nil)
        
        XCTAssertNotNil(item.csv)
    }


    func testJSONConversion() {
            let item = TodoItem(text: "Make a call", id: "12345", importance: .regular, deadline: Date(timeIntervalSince1970: 1623807600), done: false, creationDate: Date(), changedDate: nil)
            
            let json = item.json
            
            let parsedItem = TodoItem.parse(json: json)
            
            XCTAssertEqual(item.text, parsedItem?.text)
            XCTAssertEqual(item.id, parsedItem?.id)
            XCTAssertEqual(item.importance, parsedItem?.importance)
            XCTAssertEqual(item.deadline, parsedItem?.deadline)
            XCTAssertEqual(item.done, parsedItem?.done)
            XCTAssertEqual(item.changedDate, parsedItem?.changedDate)
        }
    
    func testCSVConversion() {
            let item = TodoItem(text: "Read a book", id: "12345", importance: .regular, deadline: Date(timeIntervalSince1970: 1623807600), done: false, creationDate: Date(), changedDate: nil)
            
            let csv = item.csv
            
            let parsedItem = TodoItem.parse(csv: csv)
            
            XCTAssertEqual(item.text, parsedItem?.text)
            XCTAssertEqual(item.id, parsedItem?.id)
            XCTAssertEqual(item.importance, parsedItem?.importance)
            XCTAssertEqual(item.deadline, parsedItem?.deadline)
            XCTAssertEqual(item.done, parsedItem?.done)
        }
    
    func testParseJSON() {
            let jsonString = """
            {
                "text": "Buy groceries",
                "id": "12345",
                "importance": "regular",
                "deadline": 1623807600,
                "done": false,
                "creationDate": 1653589200,
                "changedDate": 1653589205
            }
            """
            
            let parsedItem = TodoItem.parse(json: jsonString)
            
            XCTAssertEqual(parsedItem?.text, "Buy groceries")
            XCTAssertEqual(parsedItem?.id, "12345")
            XCTAssertEqual(parsedItem?.importance, .regular)
            XCTAssertNotNil(parsedItem?.deadline)
            XCTAssertEqual(parsedItem?.done, false)
            XCTAssertNotNil(parsedItem?.creationDate)
            XCTAssertNotNil(parsedItem?.changedDate)
        }
        
    func testParseCSV() {
            let csvString = "Buy groceries,12345,regular,1623807600,false,1653589200,"
            
            let parsedItem = TodoItem.parse(csv: csvString)
            
            XCTAssertEqual(parsedItem?.text, "Buy groceries")
            XCTAssertEqual(parsedItem?.id, "12345")
            XCTAssertEqual(parsedItem?.importance, .regular)
            XCTAssertEqual(parsedItem?.deadline, Date(timeIntervalSince1970: 1623807600))
            XCTAssertEqual(parsedItem?.done, false)
            XCTAssertNil(parsedItem?.changedDate)
        }
}
