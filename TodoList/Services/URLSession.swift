//
//  URLSession.swift
//  TodoList
//
//  Created by Aisha Nurgaliyeva on 05.07.2023.
//

import Foundation

 extension URLSession {
   func data(for request: URLRequest) async throws -> (Data, URLResponse) {
     var task: URLSessionDataTask?
     return try await withTaskCancellationHandler {
       try await withCheckedThrowingContinuation { continuation in
         task = self.dataTask(with: request) { data, response, error in
           if let error = error {
             continuation.resume(throwing: error)
           } else if let data = data, let response = response {
             continuation.resume(returning: (data, response))
           } else {
               let error = NSError(domain: "https://aishunya.kz", code: 0, userInfo: nil)
               continuation.resume(throwing: error)
           }
         }
         task?.resume()
       }
     } onCancel: { [weak task] in
       task?.cancel()
     }
   }
 }
