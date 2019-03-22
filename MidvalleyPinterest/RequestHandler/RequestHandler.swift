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
    init(baseURLString: String)
    @discardableResult func request<T: Decodable>(slug: String, completion: @escaping ((Response<T>) -> ())) throws -> URLSessionTask?
}

class RequestHandlerImpl: RequestHandler {
    var baseURLString: String
    
    required init(baseURLString: String) {
        self.baseURLString = baseURLString
    }
    
    @discardableResult
    func request<T: Decodable>(slug: String, completion: @escaping ((Response<T>) -> ())) throws -> URLSessionTask? {
        // Set up the URL request
        let endpoint: String = baseURLString + slug
        guard let url = URL(string: endpoint) else {
            throw RequestError.cannotCreateURL
        }
        
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                return completion(.error(error!))
            }
            
            // check for data existance
            guard let data = data else {
                return completion(.error(ResponseError.noDataReceived))
            }
            
            // parse the result and map to object
            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                completion(.success(model))
            } catch  {
                completion(.error(error))
            }
        }
        task.resume()
        return task
    }
    
}
