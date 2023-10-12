//
//  FetchUserDetailRepository.swift
//  Project
//
//  Created by rayeon lee on 2023/06/19.
//

import RxSwift

protocol UserRepository {
    func fetchUser(with url: String) -> Observable<User>
    func fetchUserList(per_page: Int, page: Int) -> Observable<[User]>
    func updateBookmark(_ action:DataBaseActionType, _ user:User) -> Observable<Void>
    func readAll() -> Observable<[User]>
}
