//
//  FetchUsersUseCase.swift
//  Project
//
//  Created by rayeon lee on 2023/04/17.
//

import RxSwift

struct FetchUserListRequestValue {
    let per_page: Int
    let since: Int
}

protocol UserListUseCase {
    func fetchUserList(requestValue: FetchUserListRequestValue) -> Observable<[User]>
    func updateBookmark(action:DataBaseActionType, user:User) -> Observable<Void>
}

final class DefaultUserListUseCase: UserListUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func fetchUserList(requestValue: FetchUserListRequestValue) -> Observable<[User]> {
        return self.userRepository.fetchUserList(per_page: requestValue.per_page, page: requestValue.since)
            .observe(on: MainScheduler.instance)
            .flatMapLatest { [weak self] remoteUsers -> Observable<[User]> in
                guard let self = self else { return Observable.empty() }
                return self.userRepository.readAll().map { localUsers in
                    return remoteUsers.map { remoteUser in
                        var new = remoteUser
                        if localUsers.contains(remoteUser) {
                            new.mark = true
                        }else {
                            new.mark = false
                        }
                        return new
                    }
                }
            }
        
    }
    
    func updateBookmark(action:DataBaseActionType, user:User) -> Observable<Void> {
        return self.userRepository.updateBookmark(action, user)
    }
    
}
