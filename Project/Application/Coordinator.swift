//
//  Coordinator.swift
//  Project
//
//  Created by rayeon lee on 2023/09/08.
//

import Foundation
import UIKit

protocol CoordinatorFinishDelegate: AnyObject {
    func coordinatorDidFinish(childCoordinator: Coordinator)
}

protocol Coordinator : AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinator : [Coordinator] { get set }
    
    var finishDelegate: CoordinatorFinishDelegate? { get set }
    func start()
    func finish()
    
    init(_ navigationController: UINavigationController)
}

extension Coordinator {
    func finish() {
        childCoordinator.removeAll()
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}
