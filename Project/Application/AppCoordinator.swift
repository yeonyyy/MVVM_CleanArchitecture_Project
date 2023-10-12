//
//  TabCoordinator.swift
//  Project
//
//  Created by rayeon lee on 2023/09/08.
//

import Foundation
import UIKit

enum TabBarPage {
    case home
    case Bookmark
    
    init?(index: Int) {
        switch index {
        case 0:
            self = .home
        case 1:
            self = .Bookmark
        default:
            return nil
        }
    }
    
    func pageTitleValue() -> String {
        switch self {
        case .home:
            return "Home"
        case .Bookmark:
            return "Bookmark"
        }
        
    }
    
    func pageOrderNumber() -> Int {
        switch self {
        case .home:
            return 0
        case .Bookmark:
            return 1
        }
    }
    
    // Add tab icon value
    func pageiconValue() -> UIImage? {
        switch self {
        case .home:
            return UIImage(systemName: "house", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))
        case .Bookmark:
            return UIImage(systemName: "star", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))
        }
    }
    
    // Add tab icon selected / deselected color
    
    // etc
}

class AppCoordinator : NSObject, Coordinator, UITabBarControllerDelegate {
    var finishDelegate: CoordinatorFinishDelegate? = nil
    
    var childCoordinator: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var tabBarController: UITabBarController
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.setNavigationBarHidden(true, animated: false)
        
        self.tabBarController = .init()
    }
    
    func start() {
        let pages: [TabBarPage] = [.home, .Bookmark]
            .sorted(by: { $0.pageOrderNumber() < $1.pageOrderNumber() })
        
        // Initialization of ViewControllers or these pages
        let controllers: [UINavigationController] = pages.map({ getTabController($0) })
        
        //prepare tabBarController
        prepareTabBarController(withTabControllers: controllers)
        
    }
    
    private func getTabController(_ page: TabBarPage) -> UINavigationController {
        let navController = UINavigationController()
        navController.setNavigationBarHidden(false, animated: false)
        
        navController.tabBarItem = UITabBarItem.init(title: page.pageTitleValue(),
                                                     image: page.pageiconValue(),
                                                     tag: page.pageOrderNumber())
        
        switch page {
        case .home:
            let usersCoordinator = DefaultUserListCoordinator(navController)
            usersCoordinator.start()
            
        case .Bookmark:
            let bookmarkCoordinator = DefaultBookmarkCoordinator(navController)
            bookmarkCoordinator.start()
            
        }
        
        return navController
    }
    
    private func prepareTabBarController(withTabControllers tabControllers: [UIViewController]) {
        /// Set delegate for UITabBarController
        tabBarController.delegate = self
        /// Assign page's controllers
        tabBarController.setViewControllers(tabControllers, animated: true)
        /// Let set index
        tabBarController.selectedIndex = TabBarPage.home.pageOrderNumber()
        /// Styling
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            
            tabBarController.tabBar.scrollEdgeAppearance = appearance
            tabBarController.tabBar.standardAppearance = appearance
        }else {
            tabBarController.tabBar.barTintColor = .white
            tabBarController.tabBar.isTranslucent = false
        }
        
        /// In this step, we attach tabBarController to navigation controller associated with this coordanator
        navigationController.viewControllers = [tabBarController]
    }
    
}
