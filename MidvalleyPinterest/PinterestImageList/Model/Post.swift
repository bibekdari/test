//
//  Post.swift
//  MidvalleyPinterest
//
//  Created by bibek timalsina on 3/21/19.
//  Copyright © 2019 bibek timalsina. All rights reserved.
//

import Foundation

struct Post: Decodable {
    var id: String
    var width: Int
    var height: Int
    var likes: Int
    var likedByUser: Bool
    var user: User
    var urls: PostURL
}

struct PostURL: Decodable {
    var raw: String
    var full: String
    var regular: String
    var small: String
    var thumb: String
}
