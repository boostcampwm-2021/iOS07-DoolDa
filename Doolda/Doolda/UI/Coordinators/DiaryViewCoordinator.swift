//
//  DiaryViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/02.
//

import UIKit

class DiaryViewCoordinator: Coordinator {
    private let user: User
    
    init(presenter: UINavigationController, parent: Coordinator? = nil, user: User) {
        self.user = user
        super.init(presenter: presenter, parent: parent)
    }
    
    override func start() {
        DispatchQueue.main.async {
            let viewController = DiaryViewController()
            self.presenter.setViewControllers([viewController], animated: false)
        }
    }
}
