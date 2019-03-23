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
    @discardableResult func request<T: Decodable>(slug: String, parameters: [String: String], shouldCache: Bool, completion: @escaping ((Response<T>) -> ())) throws -> TaskManager.Task?
}

class RequestHandlerImpl: RequestHandler {

    let baseURLString: String
    let snakeCaseDecoding: Bool
    let taskManager: TaskManager
    
    init(baseURLString: String, taskManager: TaskManager = .default, snakeCaseDecoding: Bool = true) {
        self.baseURLString = baseURLString
        self.snakeCaseDecoding = snakeCaseDecoding
        self.taskManager = taskManager
    }
    
    @discardableResult
    func request<T: Decodable>(slug: String, parameters: [String: String], shouldCache: Bool, completion: @escaping ((Response<T>) -> ())) throws -> TaskManager.Task? {
        // Set up the URL request
        let endpoint: String = baseURLString + slug
        guard let urlComponents = URLComponents(string: endpoint) else {
            throw RequestError.cannotCreateURL
        }
        
        return try taskManager.request(urlComponents: urlComponents, parameters: parameters, shouldCache: shouldCache, completion: { (response) in
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
