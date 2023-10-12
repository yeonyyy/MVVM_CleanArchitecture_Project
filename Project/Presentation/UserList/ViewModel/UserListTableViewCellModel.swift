//
//  UserInfoViewModel.swift
//  Project
//
//  Created by rayeon lee on 2023/06/15.
//

import RxCocoa
import RxSwift

class UserListTableViewCellModel {
    let title = BehaviorRelay<String?>(value: nil)
    let imagePath = BehaviorRelay<String?>(value: nil)
    let bookmark = BehaviorRelay<Bool>(value: false)
    
    let user: User
    
    init(with user: User) {
        self.user = user
        title.accept(user.login)
        imagePath.accept(user.avatar_url)
        bookmark.accept(user.mark)
    }
    
}
