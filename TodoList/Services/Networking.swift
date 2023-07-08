//
//  Networking.swift
//  TodoList
//
//  Created by Aisha Nurgaliyeva on 06.07.2023.
//

import Foundation

import UIKit

protocol NetworkingService {
    func getItemsList(completion: (([TodoItem]) -> Void)?,
                      failure: ((RequestError) -> Void)?)
    func syncItemsListWithServer(items: [TodoItem],
                                 completion: (([TodoItem]) -> Void)?,
                                 failure: ((RequestError) -> Void)?)
    func getItemById(id: String,
                     completion: (([TodoItem]) -> Void)?,
                     failure: ((RequestError) -> Void)?)
    func addSingleItem(item: TodoItem,
                       completion: (([TodoItem]) -> Void)?,
                       failure: ((RequestError) -> Void)?)
    func changeSingleItem(item: TodoItem,
                          completion: (([TodoItem]) -> Void)?,
                          failure: ((RequestError) -> Void)?)
    func deleteItemById(id: String,
                        completion: (([TodoItem]) -> Void)?,
                        failure: ((RequestError) -> Void)?)
}

class DefaultNetworkingService: NetworkingService {
    private let scheme = "https"
    private let host = "beta.mrdekk.ru"
    private let defaultPath = "todobackend"
    private let bearerToken = "superinfection"

    private let httpStatusCodeSuccess = 200..<300
    private let httpStatusCodeBadRevision = 400..<500
    private let httpStatusCodeServerError = 500..<600

    private var requestTimeout = 3.0
    private let maxAttepmtCount = 3

    private let minDelay = 2.0
    private let maxDelay = 120.0
    private let delayFactor = 1.5
    private let jitter = 0.05

    private var currentRevision: Int

    init() {
        self.currentRevision = UserDefaults.standard.integer(forKey: Identifiers.revision.rawValue)
    }

    func getItemsList(completion: (([TodoItem]) -> Void)?,
                      failure: ((RequestError) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            guard let request = self.createBaseRequest(failure: failure,
                                                       path: "list")
            else { return }
            self.sendRequest(request: request, completion: completion, failure: failure, useRetry: false)
        }
    }

    func syncItemsListWithServer(items: [TodoItem],
                                 completion: (([TodoItem]) -> Void)?,
                                 failure: ((RequestError) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            let item = ServerItemsListRequest(list: items.map { NetworkToDoItem($0) })
            guard let data = try? JSONEncoder().encode(item)
            else {
                failure?(.serializationListError(item))
                return
            }

            guard let request = self.createBaseRequest(failure: failure,
                                                       path: "list",
                                                       httpMethod: "PATCH",
                                                       revision: self.currentRevision,
                                                       httpBody: data)
            else { return }
            self.sendRequest(request: request, completion: completion, failure: failure)
        }
    }

    func getItemById(id: String,
                     completion: (([TodoItem]) -> Void)?,
                     failure: ((RequestError) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            guard let request = self.createBaseRequest(failure: failure,
                                                  path: "list/\(id)")
            else { return }
            self.sendRequest(request: request, completion: completion, failure: failure)
        }
    }

    func addSingleItem(item: TodoItem,
                       completion: (([TodoItem]) -> Void)?,
                       failure: ((RequestError) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            let item = ServerSingleItemRequest(element: NetworkToDoItem(item))
            guard let data = try? JSONEncoder().encode(item)
            else {
                failure?(.serializationSingleError(item))
                return
            }

            guard let request = self.createBaseRequest(failure: failure,
                                                       path: "list",
                                                       httpMethod: "POST",
                                                       revision: self.currentRevision,
                                                       httpBody: data)
            else { return }
            self.sendRequest(request: request, completion: completion, failure: failure)
        }
    }

    func changeSingleItem(item: TodoItem,
                          completion: (([TodoItem]) -> Void)?,
                          failure: ((RequestError) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            let id = item.id
            let item = ServerSingleItemRequest(element: NetworkToDoItem(item))
            guard let data = try? JSONEncoder().encode(item)
            else {
                failure?(.serializationSingleError(item))
                return
            }

            guard let request = self.createBaseRequest(failure: failure,
                                                       path: "list/\(id)",
                                                       httpMethod: "PUT",
                                                       revision: self.currentRevision,
                                                       httpBody: data)
            else { return }
            self.sendRequest(request: request, completion: completion, failure: failure)
        }
    }

    func deleteItemById(id: String,
                        completion: (([TodoItem]) -> Void)?,
                        failure: ((RequestError) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            guard let request = self.createBaseRequest(failure: failure,
                                                       path: "list/\(id)",
                                                       httpMethod: "DELETE",
                                                       revision: self.currentRevision)
            else { return }
            self.sendRequest(request: request, completion: completion, failure: failure)
        }
    }

    private func sendRequest(request: URLRequest,
                             completion: (([TodoItem]) -> Void)?,
                             failure: ((RequestError) -> Void)?,
                             useRetry: Bool = true,
                             attempt: Int = 0) {
        if attempt >= maxAttepmtCount {
            failure?(.connectionError)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if self.isNeedRetry(response: response, error: error) {
                if !useRetry {
                    failure?(.connectionError)
                    return
                }
                let attemptUp = attempt + 1
                print("Connection failed. Attepmt \(attemptUp)")
                let secondsDelay = self.createDelay(currentAttempt: attemptUp)
                let microsecDelay = Int(secondsDelay * 1000000)
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .microseconds(microsecDelay)) {
                    self.sendRequest(request: request, completion: completion, failure: failure, attempt: attempt + 1)
                }
                return
            }

            if let requestError = self.checkRequestError(response: response, error: error) {
                failure?(requestError)
                return
            }

            guard let data = data
            else {
                failure?(.nullDataResponce(response))
                return
            }

            guard let items = self.parseServerData(data: data)
            else {
                failure?(.deserializationError(data))
                return
            }
            completion?(items)
        }.resume()
    }

    private func createBaseRequest(failure: ((RequestError) -> Void)?,
                                   path: String,
                                   httpMethod: String = "GET",
                                   revision: Int? = nil,
                                   httpBody: Data? = nil) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "/\(defaultPath)/\(path)"

        guard let url = urlComponents.url
        else {
            failure?(RequestError.wrongUrl(urlComponents))
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue( "Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = httpMethod
        request.httpBody = httpBody
        request.timeoutInterval = requestTimeout
        if let revision = revision {
            request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        }
        return request
    }
    
    private func checkRequestError(response: URLResponse?, error: Error?) -> RequestError? {
        guard let response = response
        else {
            if let error = error {
                return .requestError(error)
            }
            return .unknownError
        }

        guard let response = response as? HTTPURLResponse
        else { return .unexpectedResponce(response) }

        guard self.httpStatusCodeSuccess.contains(response.statusCode)
        else {
            if httpStatusCodeBadRevision.contains(response.statusCode) {
                return .badRevision
            }
            return .failedResponce(response)
        }

        return nil
    }

    private func saveRevision(revision: Int) {
        currentRevision = revision
        UserDefaults.standard.set(currentRevision, forKey: Identifiers.revision.rawValue)
    }

    private func parseServerData(data: Data) -> [TodoItem]? {
        guard let singleItem = parseServerSingleData(data: data)
        else {
            guard let listItems = parseServerListData(data: data)
            else { return nil }

            return listItems
        }

        return singleItem
    }

    private func parseServerListData(data: Data) -> [TodoItem]? {
        guard let itemsAtResponce = try? JSONDecoder().decode(ServerItemsListResponce.self, from: data)
        else { return nil }
        self.saveRevision(revision: itemsAtResponce.revision)
        return itemsAtResponce.list.map { $0.toToDoItem() }
    }

    private func parseServerSingleData(data: Data) -> [TodoItem]? {
        guard let itemAtResponce = try? JSONDecoder().decode(ServerSingleItemResponce.self, from: data)
        else { return nil }
        self.saveRevision(revision: itemAtResponce.revision)
        return [itemAtResponce.element.toToDoItem()]
    }

    private func isNeedRetry(response: URLResponse?, error: Error?) -> Bool {
        guard let response = response as? HTTPURLResponse
        else {
            if (error as? URLError)?.code == .timedOut {
                requestTimeout *= 1.5
                return true
            }
            return false
        }

        return httpStatusCodeServerError.contains(response.statusCode)
    }

    private func createDelay(currentAttempt: Int) -> Double {
        var delay = exp(self.delayFactor * Double(currentAttempt))
        let jitterValue = Double.random(in: -jitter...jitter) * delay
        delay += jitterValue
        delay = max(self.minDelay, delay)
        delay = min(self.maxDelay, delay)

        return delay
    }
}

enum RequestError: Error, Equatable {
    case wrongUrl(URLComponents)
    case nullDataResponce(URLResponse?)
    case serializationListError(ServerItemsListRequest)
    case serializationSingleError(ServerSingleItemRequest)
    case connectionError
    case badRevision
    case unexpectedResponce(URLResponse)
    case failedResponce(HTTPURLResponse)
    case deserializationError(Data)
    case requestError(Error)
    case unknownError

    static func == (lhs: RequestError, rhs: RequestError) -> Bool {
        switch(lhs, rhs) {
        case (.wrongUrl(_), .wrongUrl(_)):
            return true
        case (.nullDataResponce(_), .nullDataResponce(_)):
            return true
        case (.serializationListError(_), .serializationListError(_)):
            return true
        case (.serializationSingleError(_), .serializationSingleError(_)):
            return true
        case (.connectionError, .connectionError):
            return true
        case (.badRevision, .badRevision):
            return true
        case (.unexpectedResponce(_), .unexpectedResponce(_)):
            return true
        case (.failedResponce(_), .failedResponce(_)):
            return true
        case (.deserializationError(_), .deserializationError(_)):
            return true
        case (.requestError(_), .requestError(_)):
            return true
        case (.unknownError, .unknownError):
            return true
        default:
            return false
        }
    }
}


struct ServerItemsListRequest: Codable {
    let list: [NetworkToDoItem]
}

struct ServerSingleItemRequest: Codable {
    let element: NetworkToDoItem
}

struct ServerItemsListResponce: Codable {
    let status: String
    let list: [NetworkToDoItem]
    let revision: Int
}

struct ServerSingleItemResponce: Codable {
    let status: String
    let element: NetworkToDoItem
    let revision: Int
}

struct NetworkToDoItem: Codable {
    let id: String
    let text: String
    let importance: String
    let deadline: Int64?
    let done: Bool
    let color: String?
    let createdAt: Int64
    let changedAt: Int64
    let lastUpdatedBy: String

    private enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadline
        case done
        case color
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }

    init(id: String,
         text: String,
         importance: String,
         deadline: Int64?,
         done: Bool,
         color: String?,
         createdAt: Int64,
         changedAt: Int64,
         lastUpdatedBy: String) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.done = done
        self.color = color
        self.createdAt = createdAt
        self.changedAt = changedAt
        self.lastUpdatedBy = lastUpdatedBy
    }

    init(_ item: TodoItem) {
        let creationDate = NetworkToDoItem.dateToInt64(item.creationDate) ?? 0

        self.init(id: item.id,
                  text: item.text,
                  importance: NetworkToDoItem.importanceToString(item.importance),
                  deadline: NetworkToDoItem.dateToInt64(item.deadline),
                  done: item.done,
                  color: nil,
                  createdAt: creationDate,
                  changedAt: NetworkToDoItem.dateToInt64(item.changedDate) ?? creationDate,
                  lastUpdatedBy: item.lastUpdatedBy!)
    }

    func toToDoItem() -> TodoItem {
        var deadlineDate: Date?
        if let deadline = deadline {
            deadlineDate = NetworkToDoItem.int64ToDate(deadline)
        }

        return TodoItem(text: text,
                        id: id,
                        importance: NetworkToDoItem.stringToImportance(importance),
                        deadline: deadlineDate,
                        done: done,
                        creationDate: NetworkToDoItem.int64ToDate(createdAt),
                        changedDate: NetworkToDoItem.int64ToDate(changedAt),
                        lastUpdatedBy: lastUpdatedBy)
    }

    private static func importanceToString(_ importance: Importance) -> String {
        switch importance {
        case .unimportant:
            return "low"
        case .regular:
            return "basic"
        case .important:
            return "important"
        }
    }

    private static func stringToImportance(_ importanceStr: String) -> Importance {
        switch importanceStr {
        case "low":
            return .unimportant
        case "important":
            return .important
        default:
            return .regular
        }
    }

    private static func dateToInt64(_ date: Date?) -> Int64? {
        guard let timeInterval = date?.timeIntervalSince1970
        else { return nil }
        return Int64(timeInterval * 1000)
    }

    private static func int64ToDate(_ timestamp: Int64) -> Date {
        let timeInterval = Double(timestamp) / 1000
        return Date(timeIntervalSince1970: timeInterval)
    }
}


enum Identifiers: String {
    case taskCell = "ToDoItemCell"
    case revision = "revision"
}
