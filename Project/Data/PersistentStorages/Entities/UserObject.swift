//
//  UserObject.swift
//  Project
//
//  Created by rayeon lee on 2023/07/06.
//

import Foundation
import RealmSwift

protocol RealmRepresentable {
    associatedtype RealmType: DomainConvertibleType
    var id: Int { get }
    func asRealm() -> RealmType
}

protocol DomainConvertibleType {
    associatedtype DomainType

    func asDomain() -> DomainType
}

class UserObject: Object {
    @Persisted var id: Int = 0
    @Persisted var login: String = ""
    @Persisted var avatar_url: String = ""
    @Persisted var url: String = ""
    @Persisted var followers_url: String = ""
    @Persisted var following_url: String = ""
    @Persisted var blog: String?
    @Persisted var email: String?
    @Persisted var name: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(user: User) {
        self.init()
        self.id = user.id
        self.login = user.login
        self.avatar_url = user.avatar_url
        self.url = user.url
        self.followers_url = user.followers_url
        self.following_url = user.following_url
        self.blog = user.blog
        self.email = user.email
        self.name = user.name
    }

}

extension UserObject: DomainConvertibleType {
    func asDomain() -> User {
        return User(id: id,
                    login: login,
                    avatar_url: avatar_url,
                    url: url,
                    followers_url: followers_url,
                    following_url: following_url,
                    blog: blog,
                    email: email,
                    name: name,
                    mark: true)
    }
}

extension User: RealmRepresentable {
    func asRealm() -> UserObject {
        return UserObject(user: self)
    }
}
