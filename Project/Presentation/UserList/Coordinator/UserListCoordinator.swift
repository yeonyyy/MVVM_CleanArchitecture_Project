//
//  UserProfilesCoordinator.swift
//  Project
//
//  Created by rayeon lee on 2023/09/11.
//

import UIKit

protocol UserListCoordinator : Coordinator {
    func navigateToDetail(with user: User)
}

class DefaultUserListCoordinator : UserListCoordinator {
    
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    weak var finishDelegate: CoordinatorFinishDelegate? = nil
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vm = UserListViewModel(userListUseCase:
                                    DefaultUserListUseCase(userRepository: DefaultUserRepository(dataTransferService: DefaultDataTransferService(with: DefaultNetworkService(config: ApiDataNetworkConfig(baseURL: URL(string: "https://api.github.com")!,headers: [ "Accept":"application/vnd.github+json"]))))))
        let viewController = UserListViewController(coordinator: self, viewModel: vm)
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    func navigateToDetail(with user: User) {
        let vm = UserDetailViewModel(user: user,
                               userDetailUseCase:
                                DefaultUserDetailUseCase(userRepository: DefaultUserRepository(dataTransferService: DefaultDataTransferService(with: DefaultNetworkService(config: ApiDataNetworkConfig(baseURL: URL(string: "https://api.github.com")!,headers: [ "Accept":"application/vnd.github+json"]))))))
        let viewController = UserDetailViewController(viewModel: vm)
        navigationController.pushViewController(viewController, animated: true)

    }
    
}
