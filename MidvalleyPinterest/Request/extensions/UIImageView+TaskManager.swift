//
//  UIImageView+TaskManager.swift
//  MidvalleyPinterest
//
//  Created by bibek timalsina on 3/22/19.
//  Copyright © 2019 bibek timalsina. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setImage(from url: URL, placeHolderImage: UIImage?) {
        self.image = placeHolderImage
        let taskManager = TaskManager(withCacheManager: CacheManager.shared)
        taskManager.request(url: url) { [weak self] (response) in
            switch response {
            case .success(let data):
                let image = UIImage(data: data)
                self?.image = image
            case .error(_): break
            }
        }
    }
    
}
