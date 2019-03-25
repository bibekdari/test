//
//  TaskManagerTests.swift
//  MidvalleyPinterestTests
//
//  Created by bibek timalsina on 3/25/19.
//  Copyright © 2019 bibek timalsina. All rights reserved.
//

import XCTest
@testable import MidvalleyPinterest

class TaskManagerTests: XCTestCase {
    let timeout: Double = 5
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        TaskManager.default.cacheManager?.emptyCache()
    }
    
    func testThatTaskmanagerCanDownloadAJSON() {
        let taskManager = TaskManager()
        
        let urlComponents = URLComponents(string: "http://pastebin.com/raw/wgkJgazE")!
        
        let expectation = self.expectation(description: "json downloaded from url")
        var dataResponse: DataResponse?
        let task = try! taskManager.request(urlComponents: urlComponents, parameters: [:]) { (response) in
            dataResponse = response
            expectation.fulfill()
        }
        
        XCTAssertNotNil(task, "Task shouldn't be nil")
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertNotNil(dataResponse, "data response shouldn't be nil")
        XCTAssertNotNil(dataResponse?.data, "Data response's data should not be nil")
        
        
        let json = try? JSONSerialization.jsonObject(with: dataResponse!.data!
            , options: .allowFragments)
        let posts = json as? [[String: Any]]
        let firstPostId = posts?.first?["id"] as? String
        XCTAssert(firstPostId == "4kQA1aQK8-Y", "first post id must be 4kQA1aQK8-Y")
    }
    
}
