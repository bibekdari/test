//
//  PinterestImageListConfigurator.swift
//  MidvalleyPinterest
//
//  Created by bibek timalsina on 3/22/19.
//  Copyright © 2019 bibek timalsina. All rights reserved.
//

import UIKit

class PinterestImageListConfigurator {
    
    func configuredViewController(with taskManager: TaskManager) -> PinterestViewController? {
        let sb = UIStoryboard(name: "Pinterest", bundle: nil)
        let viewController = sb.instantiateInitialViewController() as? PinterestViewController
        viewController?.requestHandler = RequestHandlerImpl(baseURLString: "http://pastebin.com", taskManager: taskManager)
        
        return viewController
    }
    
}
