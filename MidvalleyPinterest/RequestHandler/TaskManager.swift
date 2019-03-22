//
//  TaskManager.swift
//  MidvalleyPinterest
//
//  Created by bibek timalsina on 3/22/19.
//  Copyright © 2019 bibek timalsina. All rights reserved.
//

import Foundation

enum DataResponse {
    case error(Error)
    case success(Data)
}

class TaskManager {
    
    let cacheManager: CacheManager
    
    init(withCacheManager cacheManager: CacheManager) {
        self.cacheManager = cacheManager
    }
    
    @discardableResult
    func request(url: URL, shouldCache: Bool = true, completion: @escaping ((DataResponse) -> ())) -> URLSessionTask? {
        
        // return if data is available in cache
        if shouldCache {
            if let data = cacheManager.getDataFromCache(for: url.absoluteString) {
                completion(.success(data))
                return nil
            }
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
            completion(.success(data))
            
            // cache data if needs to be cached
            if shouldCache {
                self.cacheManager.cache(data: data, forKey: url.absoluteString)
            }
        }
        task.resume()
        return task
    }

}
