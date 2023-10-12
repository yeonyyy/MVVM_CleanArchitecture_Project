//
//  BookmarkViewModel.swift
//  Project
//
//  Created by rayeon lee on 2023/07/05.
//

import Foundation
import RxSwift
import RxCocoa

protocol BookmarkViewModelInputs {
    var refreshModels : PublishSubject<Void> { get }
    var selectModel : PublishSubject<UserListTableViewCellModel> { get }
    var markModel : PublishSubject<(DataBaseActionType, Int, UserListTableViewCellModel)> { get }
}

protocol BookmarkViewModelOutputs {
    var refreshCompleted : Signal<Void> { get }
    var users : Driver<[UserListTableViewCellModel]> { get }
    var showModel : Signal<User> { get }
    var markCompleted : Signal<Int> { get }
}

protocol BookmarkViewModelType {
    var inputs: BookmarkViewModelInputs { get }
    var outputs: BookmarkViewModelOutputs { get }
}

class BookmarkViewModel : BookmarkViewModelType, BookmarkViewModelInputs, BookmarkViewModelOutputs {
    var inputs: BookmarkViewModelInputs { return self }
    var outputs: BookmarkViewModelOutputs { return self }
    
    //MARK: -- Inputs
    var refreshModels = PublishSubject<Void>()
    var selectModel = PublishSubject<UserListTableViewCellModel>()
    var markModel = PublishSubject<(DataBaseActionType, Int, UserListTableViewCellModel)>()
    
    //MARK: -- Outputs
    var refreshCompleted = PublishRelay<Void>().asSignal()
    var users =  BehaviorRelay<[UserListTableViewCellModel]>(value: []).asDriver()
    var showModel = PublishRelay<User>().asSignal()
    var markCompleted = PublishRelay<Int>().asSignal()
    
    private let bookmarkUseCase : BookmarkUseCase
    private let disposeBag = DisposeBag()
    
    init(_ bookmarkUseCase : BookmarkUseCase) {
        self.bookmarkUseCase = bookmarkUseCase
        
        let users = BehaviorRelay<[User]>(value: [])
        self.users = users.map { $0.map { UserListTableViewCellModel(with: $0) } }.asDriver(onErrorJustReturn: [])
        
        let refreshCompleted = PublishRelay<Void>()
        self.refreshCompleted = refreshCompleted.asSignal()
        
        let showModel = PublishRelay<User>()
        self.showModel = showModel.asSignal()
        
        let markCompleted = PublishRelay<Int>()
        self.markCompleted = markCompleted.asSignal()
        
        refreshModels
            .flatMapLatest({ [weak self] _ -> Observable<[User]> in
                guard let self = self else { return Observable.empty() }
                return self.bookmarkUseCase.readUsers()
            })
            .subscribe(onNext: {
                refreshCompleted.accept(())
                users.accept($0)
            }).disposed(by: disposeBag)
        
        selectModel
            .map{ $0.user }
            .subscribe(onNext: {
                showModel.accept($0)
            }).disposed(by: disposeBag)
        
        markModel
            .flatMapLatest({ [weak self] (action, index, cell) -> Observable<(Int,DataBaseActionType)> in
                guard let self = self else { return Observable.empty() }
                return self.bookmarkUseCase.updateBookmark(action: action, user: cell.user)
                    .map { _ in (index, action) }
            })
            .subscribe(onNext: { (idx, action) in
                var userValue = users.value
                userValue[idx].mark = action == DataBaseActionType.add ? true : false
                users.accept(userValue)
                markCompleted.accept(idx)
            }).disposed(by: disposeBag)
                    
                    
        }
    
    
}
