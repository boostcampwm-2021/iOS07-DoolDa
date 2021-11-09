//
//  EditPageViewCoordinator.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/09.
//

import UIKit

class EditPageViewCoordinator: EditPageViewCoordinatorProtocol {
    
    var presenter: UINavigationController
    private let user: User
    
    init(presenter: UINavigationController, user: User) {
        self.presenter = presenter
        self.user = user
    }
    
    func start() {
        DispatchQueue.main.async {
            let viewController = EditPageViewController()
            self.presenter.setViewControllers([viewController], animated: false)
        }
    }
    
    func editingPageSaved() {}
    
    func editingPageCanceled() {}
}
