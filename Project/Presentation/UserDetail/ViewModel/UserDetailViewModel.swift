//
//  UserDetailViewModel.swift
//  Project
//
//  Created by rayeon lee on 2023/04/04.
//

import Foundation
import RxSwift
import RxCocoa

protocol UserViewModelInputs {
    var fetchModel : PublishSubject<Void> { get }
}

protocol UserViewModelOutputs {
    var title: Driver<String> { get }
    var fullname: Driver<String> { get }
    var blog: Driver<String?> { get }
    var email: Driver<String?> { get }
    var image: Driver<UIImage?> { get }
    var error: Signal<String?> { get }
}

protocol UserViewModelType {
    var inputs: UserViewModelInputs { get }
    var outputs: UserViewModelOutputs { get }
}

class UserViewModel : UserViewModelType, UserViewModelInputs, UserViewModelOutputs{
    var outputs: UserViewModelOutputs { return self }
    var inputs: UserViewModelInputs { return self }
    
    // MARK: - Inputs
    var fetchModel = PublishSubject<Void>()
    private var user = BehaviorRelay<User>(value: User.defaultValue)
    
    // MARK: - Outputs
    var title = BehaviorRelay<String>(value: "").asDriver()
    var fullname = BehaviorRelay<String>(value: "").asDriver()
    var blog = BehaviorRelay<String?>(value: "").asDriver()
    var email = BehaviorRelay<String?>(value: "").asDriver()
    var image = BehaviorRelay<UIImage?>(value: nil).asDriver()
    var error = PublishRelay<String?>().asSignal()
    
    private let disposeBag = DisposeBag()
    
    private var userDetailUseCase: UserDetailUseCase
    
    init(user: User, userDetailUseCase : UserDetailUseCase) {
        self.userDetailUseCase = userDetailUseCase
        self.user.accept(user)

        inputs.fetchModel
            .withLatestFrom(self.user)
            .map{ $0.login }
            .flatMap({ [weak self] (login) -> Observable<User> in
                guard let self = self else { return Observable.empty() }
                return self.userDetailUseCase.execute(with: login)
                    .catch { err in
                        return Observable.empty()
                    }
            })
            .subscribe(onNext: { [weak self] userinfo in
                guard let self = self else { return }
                self.user.accept(userinfo)
            }).disposed(by: disposeBag)
     
        title = self.user.map{ $0.login }.asDriver(onErrorJustReturn: "")
        fullname = self.user.map{ $0.name ?? "" }.asDriver(onErrorJustReturn: "")
        blog = self.user.map{ $0.blog ?? "" }.asDriver(onErrorJustReturn: "")
        email = self.user.map{ $0.email ?? "" }.asDriver(onErrorJustReturn: "")
        image = self.user.map{ $0.avatar_url }
            .flatMap { ImageCacheService.shared.loadImage(from: $0) }
            .filter { $0 != nil }
            .asDriver(onErrorJustReturn: nil)
        
    }
    
}
