//
//  Cache.swift
//  MidvalleyPinterest
//
//  Created by bibek timalsina on 3/22/19.
//  Copyright © 2019 bibek timalsina. All rights reserved.
//

import Foundation

class CacheManager {
    
    static let `default` = CacheManager(ofSize: 104857600)
    
    var size: Int
    private var cache: [String: (data: Data, lastUsedDate: Date, size: Int)] = [:]
    private var currentCacheSize: Int = 0
    
    private init(ofSize size: Int) {
        self.size = size
    }
    
    func getDataFromCache(for key: String) -> Data? {
        guard let (data, _, _) = cache[key] else {
            return nil
        }
        cache(data: data, forKey: key)
        return data
    }
    
    func cache(data: Data, forKey key: String) {
        removeFromCache(key)
        
        let dataSize = data.count
        
        // check if data can be accomodated in cache
        guard dataSize < size else {
            return
        }
        
        // if adding new data in cache exceeds size of cache then free the cache by removing old data
        if (currentCacheSize + dataSize) > size {
            freeCache(ofSize: dataSize)
        }
        
        cache[key] = (data, Date(), dataSize)
    }
    
    private func removeFromCache(_ key: String) {
        if let removedObject = cache.removeValue(forKey: key) {
            currentCacheSize -= removedObject.data.count
        }
    }
    
    private func freeCache(ofSize freeSize: Int) {
        let sortedCache = cache.sorted(by: {$0.value.lastUsedDate < $1.value.lastUsedDate})
        
        // get all keys that needs to be removed to obtain free size
        var keysToRemove: [String] = []
        var removingSize = 0
        for object in sortedCache {
            removingSize += object.value.size
            if removingSize >= freeSize {
                break
            }
            keysToRemove.append(object.key)
        }
        keysToRemove.forEach(removeFromCache)
    }
    
    func emptyCache() {
        cache = [:]
        currentCacheSize = 0
    }
}
