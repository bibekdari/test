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
    
    struct Task: Equatable {
        let id: String = UUID().uuidString
        let url: URL
        fileprivate let taskManager: TaskManager?
        fileprivate let sessionTask: URLSessionTask?
        fileprivate let completion: ((DataResponse) -> ())?
        
        func cancel() {
            taskManager?.cancelTask(self)
        }
        
        static func ==(lhs: Task, rhs: Task) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    static let `default` = TaskManager(withCacheManager: CacheManager.default)
    
    let cacheManager: CacheManager
    
    private var urlTasks: [URL: [Task]] = [:]
    
    init(withCacheManager cacheManager: CacheManager) {
        self.cacheManager = cacheManager
    }
    
    @discardableResult
    func request(urlComponents: URLComponents, parameters: [String: String], shouldCache: Bool = true, completion: @escaping ((DataResponse) -> ())) throws -> Task? {
        var urlComponents = urlComponents
        var queryItems = urlComponents.queryItems ?? []
        parameters.forEach { parameter in
            queryItems.append(URLQueryItem(name: parameter.key, value: parameter.value))
        }
        urlComponents.queryItems = queryItems
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        guard let url = urlComponents.url else {
            throw RequestError.cannotCreateURL
        }
        // return if data is available in cache
        if shouldCache {
            if let data = cacheManager.getDataFromCache(for: url.absoluteString) {
                completion(.success(data))
                return nil
            }
        }
        
        print(url.pathComponents)
        
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let dataTask = session.dataTask(with: urlRequest) {
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
        dataTask.resume()
        
        let task = Task(url: url, taskManager: self, sessionTask: dataTask, completion: completion)
        addTask(task)
        
        return task
    }
    
    @discardableResult
    func download(url: URL, shouldCache: Bool = true, completion: @escaping ((DataResponse) -> ())) -> Task? {
        
        // return if data is available in cache
        if shouldCache {
            if let data = cacheManager.getDataFromCache(for: url.absoluteString) {
                completion(.success(data))
                return nil
            }
        }
        
        // continue only if task is new
        guard urlTasks[url] == nil else {
            let task = Task(url: url, taskManager: self, sessionTask: nil, completion: completion)
            addTask(task)
            return task
        }
        
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let dataTask = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                return self.sendCompletions(.error(error!), ofURL: url)
            }
            
            // check for data existance
            guard let data = data else {
                return self.sendCompletions(.error(ResponseError.noDataReceived), ofURL: url)
            }
            self.sendCompletions(.success(data), ofURL: url)
            
            // cache data if needs to be cached
            if shouldCache {
                self.cacheManager.cache(data: data, forKey: url.absoluteString)
            }
        }
        dataTask.resume()
        
        let task = Task(url: url, taskManager: self, sessionTask: dataTask, completion: completion)
        addTask(task)
        
        return task
    }
    
    private func sendCompletions(_ response: DataResponse, ofURL url: URL) {
        let tasks = urlTasks[url]
        tasks?.forEach({ (task) in
            task.completion?(response)
        })
        urlTasks.removeValue(forKey: url)
    }
    
    private func addTask(_ task: Task) {
        let oldTasks = urlTasks[task.url] ?? []
        urlTasks[task.url] = oldTasks + [task]
    }
    
    private func cancelTask(_ task: Task) {
        var allTasks = urlTasks[task.url] ?? []
        // cancel session task if only one task is remaining
        if allTasks.count == 1 {
            let task = allTasks.first
            task?.sessionTask?.cancel()
            allTasks = []
        }else {
            // remove task from list
            if let index = allTasks.firstIndex(of: task) {
                allTasks.remove(at: index)
            }
        }
        urlTasks[task.url] = allTasks
    }
}
