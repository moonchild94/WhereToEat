//
//  NetworkService.swift
//  WhereToEat
//
//  Created by Daria Kalmykova on 29.04.2020.
//  Copyright © 2020 Daria Kalmykova. All rights reserved.
//

import Foundation

protocol Response: Decodable {
    var status: String { get }
}

class NetworkService {
    private let baseUrl: String
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    func executeQuery<T: Response>(with params: [String: Any], completion: @escaping (T?, Error?) -> Void) {
        doExecuteQuery(with: params) { (response: T?, error: Error?) in
            if let error = error {
                NSLog("Got error on request: \(error.localizedDescription)")
            }
            completion(response, error)
        }
    }
    
    private func doExecuteQuery<T: Response>(with params: [String: Any], completion: @escaping (T?, Error?) -> Void) {
        guard let url = URL(baseUrl: baseUrl, params: params) else {
            completion(nil, NetworkServiceError.invalidRequest)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, NetworkServiceError.unknown)
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(nil, NetworkServiceError.httpError(statusCode: httpResponse.statusCode))
                return
            }
            
            guard let data = data else {
                completion(nil, NetworkServiceError.emptyResponse)
                return
            }
            
            guard let response = try? JSONDecoder().decode(T.self, from: data) else {
                completion(nil, NetworkServiceError.invalidResponse)
                return
            }
            
            guard response.status == "OK" else {
                completion(nil, NetworkServiceError.inner)
                return
            }
            
            completion(response, nil)
        }
        
        task.resume()
    }
}

enum NetworkServiceError: Error {
    case invalidRequest
    case httpError(statusCode: Int)
    case emptyResponse
    case invalidResponse
    case inner
    case unknown
}

private extension URL {
    init?(baseUrl: String, params: Dictionary<String, Any>) {
        guard var components = URLComponents(string: baseUrl) else { return nil }
        components.queryItems = params.map { pair in
            URLQueryItem(name: pair.key, value: String(describing: pair.value))
        }
        
        guard let url = components.url else { return nil }
        self = url
    }
}
