//
//  UsersResponseDTO+Mapping.swift
//  Project
//
//  Created by rayeon lee on 2023/04/13.
//

struct UserResponseDTO: Decodable {
    let login: String
    let id: Int
    let node_id: String
    let avatar_url: String
    let gravatar_id: String?
    let url: String
    let html_url: String
    let followers_url: String
    let following_url: String
    let gists_url: String
    let starred_url: String
    let subscriptions_url: String?
    let organizations_url: String?
    let repos_url: String?
    let events_url: String?
    let received_events_url: String?
    let type: String?
    let site_admin : Bool
    let name :  String?
    let company: String?
    let blog : String?
    let location : String?
    let email : String?
    let hireable : String?
    let bio : String?
    let twitter_username : String?
    let public_repos : Int?
    let public_gists: Int?
    let followers: Int?
    let following: Int?
    let created_at : String?
    let updated_at : String?
}

extension UserResponseDTO {
    func toDomain() -> User {
        return .init(id: id, login: login, avatar_url: avatar_url, url: url, followers_url: followers_url, following_url: following_url, blog: blog, email: email, name: name, mark: false)
    }
    
}
