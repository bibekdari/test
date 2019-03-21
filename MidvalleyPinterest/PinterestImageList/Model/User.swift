//
//  User.swift
//  MidvalleyPinterest
//
//  Created by bibek timalsina on 3/21/19.
//  Copyright © 2019 bibek timalsina. All rights reserved.
//

import Foundation

struct User: Decodable {
    var id: String
    var username: String
    var name: String
    var profileImage: ProfileImage
}

struct ProfileImage: Decodable {
    var small: String
    var medium: String
    var large: String
}
