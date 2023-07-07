//
//  CustomDataTaskExtension.swift
//  TodoList
//
//  Created by Aisha Nurgaliyeva on 03.07.2023.
//

import Foundation

extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        
        return (Data(), URLResponse())
    }
}
