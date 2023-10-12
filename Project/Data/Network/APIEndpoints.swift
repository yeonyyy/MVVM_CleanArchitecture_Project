//
//  Endpoint.swift
//  Project
//
//  Created by rayeon lee on 2023/04/13.
//

import Foundation

struct APIEndpoints {
    static func getUsers(with userRequestDTO: UserRequestDTO) -> Endpoint<[UserResponseDTO]> {
        return Endpoint(path: "users",
                        method: .get,
                        queryParametersEncodable: userRequestDTO)
    }
    
    static func getUserDetail(username: String) -> Endpoint<UserResponseDTO> {
        return Endpoint(path: "users/\(username)",
                        method: .get)
    }

}
