//
//  BookmarkUseCase.swift
//  Project
//
//  Created by rayeon lee on 2023/07/26.
//

import Foundation
import RxSwift

protocol BookmarkUseCase  {
    func readUsers() -> Observable<[User]>
    func updateBookmark(action:DataBaseActionType, user:User) -> Observable<Void>
}

final class DefaultBookmarkUseCase : BookmarkUseCase {
    
    private let userRepository: UserRepository!
    
    init(_ userRepository : UserRepository) {
        self.userRepository = userRepository
    }
    
    func readUsers() -> Observable<[User]> {
        return self.userRepository.readAll()
    }
    
    func updateBookmark(action:DataBaseActionType, user:User) -> Observable<Void> {
        return self.userRepository.updateBookmark(action, user)
    }
    
}
