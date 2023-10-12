//
//  FetchUserDetailUseCase.swift
//  Project
//
//  Created by rayeon lee on 2023/06/19.
//

import RxSwift

protocol UserDetailUseCase {
    func execute(with name:String) -> Observable<User>
}

final class DefaultUserDetailUseCase: UserDetailUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func execute(with name:String) -> Observable<User> {
        return self.userRepository.fetchUser(with: name)
    }
    

}
