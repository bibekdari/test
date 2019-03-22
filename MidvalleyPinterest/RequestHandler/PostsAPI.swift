//
//  PostsAPI.swift
//  MidvalleyPinterest
//
//  Created by bibek timalsina on 3/21/19.
//  Copyright © 2019 bibek timalsina. All rights reserved.
//

import Foundation

protocol PostsAPI {
    var requestHandler: RequestHandler? {get}
}

extension PostsAPI {
    
    func getPosts(success: @escaping ([Post]) -> (), failure: @escaping (Error) -> ()) throws {
        let slug = "/raw/wgkJgazE"
        _ = try requestHandler?.request(slug: slug) { (response: Response<[Post]>) in
            switch response {
            case .error(let error):
                failure(error)
            case .success(let model):
                success(model)
            }
        }
    }
    
}

