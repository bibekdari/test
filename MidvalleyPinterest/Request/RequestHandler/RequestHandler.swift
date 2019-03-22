//
//  RequestHandler.swift
//  MidvalleyPinterest
//
//  Created by bibek timalsina on 3/21/19.
//  Copyright © 2019 bibek timalsina. All rights reserved.
//

import Foundation

enum RequestError: Error {
    case cannotCreateURL
    var localizedDescription: String {
        switch self {
        case .cannotCreateURL:
            return "Cannot create URL"
        }
    }
}

enum ResponseError: Error {
    case noDataReceived
    var localizedDescription: String {
        switch self {
        case .noDataReceived:
            return "No data received."
        }
    }
}

enum Response<T: Decodable> {
    case error(Error)
    case success(T)
}

protocol RequestHandler {
    var baseURLString: String {get}
    var snakeCaseDecoding: Bool {get}
    @discardableResult func request<T: Decodable>(slug: String, completion: @escaping ((Response<T>) -> ())) throws -> URLSessionTask?
}

class RequestHandlerImpl: RequestHandler {

    let baseURLString: String
    let snakeCaseDecoding: Bool
    let taskManager: TaskManager
    
    init(baseURLString: String, taskManager: TaskManager, snakeCaseDecoding: Bool = true) {
        self.baseURLString = baseURLString
        self.snakeCaseDecoding = snakeCaseDecoding
        self.taskManager = taskManager
    }
    
    @discardableResult
    func request<T: Decodable>(slug: String, completion: @escaping ((Response<T>) -> ())) throws -> URLSessionTask? {
        // Set up the URL request
        let endpoint: String = baseURLString + slug
        guard let url = URL(string: endpoint) else {
            throw RequestError.cannotCreateURL
        }
        
        return taskManager.request(url: url, completion: { (response) in
            switch response {
            case .success(let data):
                // parse the result and map to object
                do {
                    let decoder = JSONDecoder()
                    if self.snakeCaseDecoding {
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                    }
                    let model = try decoder.decode(T.self, from: data)
                    completion(.success(model))
                } catch  {
                    completion(.error(error))
                }
            case .error(let error):
                completion(.error(error))
            }
        })
    }

}
