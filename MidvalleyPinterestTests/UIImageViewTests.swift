//
//  UIImageViewTests.swift
//  MidvalleyPinterestTests
//
//  Created by bibek timalsina on 3/25/19.
//  Copyright © 2019 bibek timalsina. All rights reserved.
//

import XCTest
@testable import MidvalleyPinterest
import UIKit

private class TestImageView: UIImageView {
    var imageObserver: (() -> Void)?
    
    convenience init(imageObserver: (() -> Void)? = nil) {
        self.init(frame: CGRect.zero)
        self.imageObserver = imageObserver
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var image: UIImage? {
        get {
            return super.image
        }
        set {
            super.image = newValue
            // call image observer after valid image is set
            if newValue != nil {
                imageObserver?()
            }
        }
    }
}

// MARK: - Test Cases

class UIImageViewTestCase: XCTestCase {
    let url = URL(string: "http://placehold.it/120x120&text=image1")!
    let timeout: Double = 5
    
    override func setUp() {
        super.setUp()
        TaskManager.default.cacheManager?.emptyCache()
    }
    
    func testThatImageIsDownloadedFromGivenURL() {
        let expectation = self.expectation(description: "Image downloads")
        var imageDownloadCompleted = false
        
        let imageView = TestImageView(imageObserver: {
            imageDownloadCompleted = true
            expectation.fulfill()
        })
        
        imageView.setImage(from: url, placeHolderImage: nil)
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertTrue(imageDownloadCompleted, "imageDownloadCompleted should be true")
    }
    
    func testThatImageDownloadsWhenMultipleRequestToSameURLIsSent() {
        
        let expectation = self.expectation(description: "Image downloads")
        var imageDownloadCompleted1 = false
        var imageDownloadCompleted2 = false
        
        let imageView = TestImageView(imageObserver: {
            imageDownloadCompleted1 = true
        })
        
        let imageView2 = TestImageView(imageObserver: {
            imageDownloadCompleted2 = true
            expectation.fulfill()
        })
        
        imageView.setImage(from: url, placeHolderImage: nil)
        imageView2.setImage(from: url, placeHolderImage: nil)
        waitForExpectations(timeout: timeout, handler: nil)
        
        XCTAssertTrue(imageDownloadCompleted1 && imageDownloadCompleted2, "imageDownloadCompleted1 and var imageDownloadCompleted2 both should be true")
    }
    
    func testThatImageIsStoredInCacheAfterDownload() {
        
        let expectation = self.expectation(description: "Image downloads")
        var imageDownloadCompleted = false
        
        let imageView = TestImageView(imageObserver: {
            imageDownloadCompleted = true
            expectation.fulfill()
        })
        
        imageView.setImage(from: url, placeHolderImage: nil)
        waitForExpectations(timeout: timeout, handler: nil)
        
        let imageFromCache = CacheManager.default.getDataFromCache(for: url.absoluteString).flatMap(UIImage.init(data:))
    
        XCTAssertTrue(imageDownloadCompleted, "imageDownloadCompleted should be true")
        XCTAssertNotNil(imageFromCache, "image from cache should not be nil")
    }
    
    func testThatSameURLImageImageRequestWontReplaceOlderRequest() {
        
        let imageView = UIImageView()
        
        imageView.setImage(from: url, placeHolderImage: nil)
        let task1 = imageView.imageDownloadTask()
        
        imageView.setImage(from: url, placeHolderImage: nil)
        let task2 = imageView.imageDownloadTask()
        
        XCTAssertTrue(task1?.id == task2?.id, "task1 id and task2 id should be same")
    }
    
}

