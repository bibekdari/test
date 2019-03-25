//
//  UIImageView+TaskManager.swift
//  MidvalleyPinterest
//
//  Created by bibek timalsina on 3/22/19.
//  Copyright © 2019 bibek timalsina. All rights reserved.
//

import UIKit

private struct Pointers {
    static var imageDownloadTask: UInt = 0
}

extension UIImageView {
    
    func setImage(from url: URL, placeHolderImage: UIImage?) {
        self.image = placeHolderImage
        
        let oldTask = imageDownloadTask()
        
        // proceed if old task url is different than new url
        guard oldTask?.url != url else {
            return
        }
        
        oldTask?.cancel()
        
        let task = TaskManager.default.download(url: url) { [weak self] (response) in
            switch response {
            case .success(let data):
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self?.image = image
                }
            case .error(_): break
            }
        }

        setTask(task: task)
    }
    
    func imageDownloadTask() -> TaskManager.Task? {
        return objc_getAssociatedObject(self, &Pointers.imageDownloadTask) as? TaskManager.Task
    }
    
    private func setTask(task: TaskManager.Task?) {
        objc_setAssociatedObject(self, &Pointers.imageDownloadTask, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
