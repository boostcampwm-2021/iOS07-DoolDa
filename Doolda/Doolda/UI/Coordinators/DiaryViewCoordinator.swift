//
//  DiaryViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/02.
//

import UIKit

class DiaryViewCoordinator: DiaryViewCoordinatorProtocol {
    
    var presenter: UINavigationController
    private let user: User
    
    init(presenter: UINavigationController, user: User) {
        self.presenter = presenter
        self.user = user
    }
    
    func start() {
        let viewModel = DiaryViewModel(coordinator: self)
        
        DispatchQueue.main.async {
            let viewController = DiaryViewController(viewModel: viewModel)
            self.presenter.setViewControllers([viewController], animated: false)
        }
    }
    
    func settingsPageRequested() {
        // FIXME: not implemented
    }
    
    func filteringSheetRequested() {
        // FIXME: not implemented
    }
}
