//
//  User.swift
//  Project
//
//  Created by rayeon lee on 2023/04/17.
//

import Foundation

struct User  {
    var id : Int
    var login : String
    var avatar_url : String
    var url : String
    var followers_url: String
    var following_url: String
    var blog : String?
    var email : String?
    var name : String?
    var mark : Bool
    
    static var defaultValue: User {
        return User(id: 0, login: "", avatar_url: "", url: "", followers_url: "", following_url: "", blog: "", email: "", name: "", mark: false)
    }
}

extension User : Equatable {
    static func == (lhs:User, rhs:User)->Bool {
        return lhs.id == rhs.id
    }
}
