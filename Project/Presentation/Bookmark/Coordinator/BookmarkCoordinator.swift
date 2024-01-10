//
//  BookmarkCoordinator.swift
//  Project
//
//  Created by rayeon lee on 2023/09/11.
//

import UIKit

protocol BookmarkCoordinator {
    func navigateToDetail(with user: User)
}

class DefaultBookmarkCoordinator : Coordinator, BookmarkCoordinator {

    var navigationController: UINavigationController
    
    var childCoordinator: [Coordinator] = []

    var finishDelegate: CoordinatorFinishDelegate?

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewcontroller = BookmarkViewController(coordinator: self,
                                                    viewModel:
                                                        BookmarkViewModel(DefaultBookmarkUseCase(DefaultUserRepository(dataTransferService: DefaultDataTransferService(with: DefaultNetworkService(config: ApiDataNetworkConfig(baseURL: URL(string: "https://api.github.com")!,headers: ["Accept":"application/vnd.github+json"])))))))
        navigationController.setViewControllers([viewcontroller], animated: false)
    }
    
    func navigateToDetail(with user: User) {
        let viewController = UserDetailViewController(viewModel:
                                                        UserDetailViewModel(user: user,
                                                                      userDetailUseCase:
                                                                        DefaultUserDetailUseCase(userRepository: DefaultUserRepository(dataTransferService: DefaultDataTransferService(with: DefaultNetworkService(config: ApiDataNetworkConfig(baseURL: URL(string: "https://api.github.com")!,headers: [ "Accept":"application/vnd.github+json"])))))))
        navigationController.pushViewController(viewController, animated: true)
        
    }
    
    
}
