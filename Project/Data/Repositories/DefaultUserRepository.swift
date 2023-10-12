//
//  DefaultFetchUsersRepository.swift
//  Project
//
//  Created by rayeon lee on 2023/04/17.
//

import RxSwift

final class DefaultUserRepository {
    private let dataTransferService : DataTransferService
    private let realmStorage : RealmStorage
    
    init (dataTransferService : DataTransferService) {
        self.dataTransferService = dataTransferService
        self.realmStorage = RealmStorage.shared
    }
}

extension DefaultUserRepository: UserRepository {
    func fetchUserList(per_page: Int, page: Int) -> Observable<[User]>{
        let requestDTO = UserRequestDTO(per_page: per_page, since: page)
        let endpoint = APIEndpoints.getUsers(with: requestDTO)
        return self.dataTransferService.request(with: endpoint)
            .map { $0.map{ $0.toDomain() } }
    }
    
    func fetchUser(with url: String) -> Observable<User> {
        let endpoint = APIEndpoints.getUserDetail(username: url)
        return self.dataTransferService.request(with: endpoint)
            .map { $0.toDomain() }
    }
    
    
    func updateBookmark(_ action:DataBaseActionType, _ user:User) -> Observable<Void> {
        return self.realmStorage.write(action: action, entity: user)
    }
    
    func readAll() -> Observable<[User]> {
        return self.realmStorage.read()
    }
    
}
