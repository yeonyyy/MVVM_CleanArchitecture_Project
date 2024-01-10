//
//  UserListViewModel.swift
//  Project
//
//  Created by rayeon lee on 2023/04/02.
//

import RxSwift
import RxCocoa

protocol UserListViewModelInputs {
    var refreshModels : PublishSubject<Void> { get }
    var loadMoreModels : PublishSubject<Void> { get }
    var selectModel : PublishSubject<UserListTableViewCellModel> { get }
    var markModel : PublishSubject<(DataBaseActionType, Int, UserListTableViewCellModel)> { get }
}

protocol UserListViewModelOutputs {
    var refreshCompleted : Signal<Void> { get }
    var isfooterLoading : Driver<Bool> { get }
    var users : Driver<[UserListTableViewCellModel]> { get }
    var showModel : Signal<User> { get }
    var markCompleted : Signal<(Int, DataBaseActionType)> { get }
    var error: Signal<String?> { get }
}

protocol UserListViewModelType {
    var inputs: UserListViewModelInputs { get }
    var outputs: UserListViewModelOutputs { get }
}

final class UserListViewModel : UserListViewModelType, UserListViewModelInputs, UserListViewModelOutputs {
    var inputs: UserListViewModelInputs { return self }
    var outputs: UserListViewModelOutputs { return self }
    
    // MARK: - Inputs
    var refreshModels = PublishSubject<Void>()
    var loadMoreModels = PublishSubject<Void>()
    var selectModel = PublishSubject<UserListTableViewCellModel>()
    var markModel = PublishSubject<(DataBaseActionType, Int, UserListTableViewCellModel)>()
    
    // MARK: - Outputs
    var refreshCompleted = PublishRelay<Void>().asSignal()
    var users = BehaviorRelay<[UserListTableViewCellModel]>(value: []).asDriver()
    var isfooterLoading = BehaviorRelay<Bool>(value: false).asDriver()
    var showModel = PublishRelay<User>().asSignal()
    var markCompleted = PublishRelay<(Int,DataBaseActionType)>().asSignal()
    var error = PublishRelay<String?>().asSignal(onErrorJustReturn: "")
    
    private let disposeBag = DisposeBag()
    private let perpage = 10
    private var since = 0
    private let userListUseCase: UserListUseCase
    
    init(userListUseCase : UserListUseCase) {
        self.userListUseCase = userListUseCase

        let users = BehaviorRelay<[User]>(value: [])
        self.users = users.map { $0.map { UserListTableViewCellModel(with: $0) } }.asDriver(onErrorJustReturn: [])
        let refreshCompleted = PublishRelay<Void>()
        self.refreshCompleted = refreshCompleted.asSignal()
        let isfooterLoading = BehaviorRelay<Bool>(value: false)
        self.isfooterLoading = isfooterLoading.asDriver()
        let showModel = PublishRelay<User>()
        self.showModel = showModel.asSignal()
        let markCompleted = PublishRelay<(Int,DataBaseActionType)>()
        self.markCompleted = markCompleted.asSignal()
        let error = PublishRelay<String?>()
        self.error = error.asSignal()
        
        inputs.refreshModels
            .flatMapLatest({ [weak self] () -> Observable<[User]> in
                guard let self = self else { return Observable.empty() }
                return self.userListUseCase.fetchUserList(requestValue: .init(per_page: self.perpage, since: 0))
                    .catch { err in
                        refreshCompleted.accept(())
                        error.accept(err.localizedDescription)
                        return Observable.empty()
                    }
            })
            .subscribe(onNext: { [weak self] (new) in
                guard let self = self else { return }
                self.since = new[new.count-1].id
                refreshCompleted.accept(())
                users.accept(new)
            }).disposed(by: disposeBag)
        
        inputs.loadMoreModels
            .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
            .do(onNext: { _ in isfooterLoading.accept(true) })
            .flatMapLatest({ [weak self] _ -> Observable<[User]> in
                guard let self = self else { return Observable.empty() }
                return self.userListUseCase.fetchUserList(requestValue: .init(per_page: self.perpage, since: self.since ))
                    .catch { err in
                        isfooterLoading.accept(false)
                        error.accept(err.localizedDescription)
                        return Observable.empty()
                    }
            })
            .map { users.value + $0 }
            .subscribe(onNext: { [weak self] (new) in
                guard let self = self else { return }
                self.since = new[new.count-1].id
                isfooterLoading.accept(false)
                users.accept(new)
            }).disposed(by: disposeBag)
        
        inputs.markModel
            .flatMapLatest({ [weak self] (action, index, model) -> Observable<(Int, DataBaseActionType)> in
                guard let self = self else { return Observable.empty() }
                return self.userListUseCase.updateBookmark(action: action, user: model.user)
                    .map { _ in (index, action) }
                    .catch { err in
                        error.accept(err.localizedDescription)
                        return Observable.empty()
                    }
            })
            .subscribe(onNext: { (idx, action) in
                var usersValue = users.value
                usersValue[idx].mark = action == DataBaseActionType.add ? true : false
                users.accept(usersValue)
                markCompleted.accept((idx,action))
            }).disposed(by: disposeBag)
        
        selectModel
            .map{ $0.user }
            .subscribe(onNext: {
                showModel.accept($0)
            }).disposed(by: disposeBag)
        
        
        
    }
    
    
}

