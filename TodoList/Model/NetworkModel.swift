//
//  NetworkModel.swift
//  TodoList
//
//  Created by Aisha Nurgaliyeva on 06.07.2023.
//

import Foundation
import UIKit

class NetworkModel {
    private var isDirty = false

    private var items = [TodoItem]()

    private let networkService: NetworkingService = DefaultNetworkingService()
    private let fileCache = FileCache()

    func getData() -> [TodoItem] {
        return items
    }
    func loadData(completion: (() -> Void)?,
                  failure: ((RequestError) -> Void)?) {

        networkService.getItemsList { loadedItems in
            self.isDirty = false
            self.items = loadedItems
            completion?()
        } failure: { error in
            self.onErrorHappend(error)
            self.items = self.getFromCache()
            failure?(error)
        }

    }

    func addOrReplaceTask(_ item: TodoItem,
                          completion: (() -> Void)?,
                          failure: ((RequestError) -> Void)?) {
        if let itemIndex = items.firstIndex(where: { $0.id == item.id }) {
            items[itemIndex] = item
            changeTask(item: item, completion: completion, failure: failure)
        } else {
            items.append(item)
            addTask(item: item, completion: completion, failure: failure)
        }
    }

    func changeTask(item: TodoItem,
                    completion: (() -> Void)?,
                    failure: ((RequestError) -> Void)?) {

        self.saveToCache(itemsToSave: self.items)

        if isDirty {
            loadData(completion: completion, failure: failure)
            return
        }

        networkService.changeSingleItem(item: item) { _ in
            completion?()
        } failure: { error in
            self.onErrorHappend(error)
            failure?(error)
        }
    }

    func addTask(item: TodoItem,
                 completion: (() -> Void)?,
                 failure: ((RequestError) -> Void)?) {

        self.saveToCache(itemsToSave: self.items)

        if isDirty {
            loadData(completion: completion, failure: failure)
            return
        }

        networkService.addSingleItem(item: item) { _ in
            completion?()
        } failure: { error in
            self.onErrorHappend(error)
            failure?(error)
            print("FAIL")
        }
    }

    func removeTask(id: String,
                    completion: (() -> Void)?,
                    failure: ((RequestError) -> Void)?) {
        guard let itemIndex = items.firstIndex(where: { $0.id == id })
        else { return }
        items.remove(at: itemIndex)

        self.saveToCache(itemsToSave: self.items)

        if isDirty {
            loadData(completion: completion, failure: failure)
            return
        }

        networkService.deleteItemById(id: id) { _ in
            completion?()
        } failure: { error in
            self.onErrorHappend(error)
            failure?(error)
        }
    }

    func toggleDone(id: String,
                         done: Bool,
                         completion: (() -> Void)?,
                         failure: ((RequestError) -> Void)?) {
        guard let itemIndex = items.firstIndex(where: { $0.id == id })
        else { return }
        let closedTask = TodoItem(
            text: items[itemIndex].text,
            id: items[itemIndex].id,
            importance: items[itemIndex].importance, deadline: items[itemIndex].deadline,
            done: done,
                                  creationDate: items[itemIndex].creationDate,
                                  changedDate: .now,
                                  lastUpdatedBy: UIDevice.current.identifierForVendor?.uuidString ?? "")
        addOrReplaceTask(closedTask, completion: completion, failure: failure)
    }

    func syncModelWithServer(completion: (() -> Void)?,
                             failure: ((RequestError) -> Void)?) {
        networkService.syncItemsListWithServer(items: getFromCache()) { _ in
            self.isDirty = false
            completion?()
        } failure: { error in
            self.onErrorHappend(error)
            self.saveToCache(itemsToSave: self.items)
            failure?(error)
        }
    }

    private func saveToCache(itemsToSave: [TodoItem]) {
        for item in itemsToSave {
            fileCache.addItem(item: item)
        }
        fileCache.saveToFile(name: "test2")
    }

    private func getFromCache() -> [TodoItem] {
        fileCache.loadFromFile(fileName: "test2")
        return fileCache.items
    }

    private func onErrorHappend(_ error: RequestError) {
        isDirty = false
    }
}
