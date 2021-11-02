//
//  SplashViewCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import UIKit

class SplashViewCoordinator: Coordinator {
    func start() {
        let viewModel = SplashViewModel(coordinatorDelegate: self)
        let viewController = SplashViewController(viewModel: viewModel)
        self.presenter.pushViewController(viewController, animated: false)
    }
}

extension SplashViewCoordinator: SplashViewCoordinatorDelegate {
    func presentParingViewController() {
        let paringViewCoordinator = ParingViewCoordinator(presenter: self.presenter, parent: self)
        self.add(child: paringViewCoordinator)
        paringViewCoordinator.start()
    }

    func presentDiaryViewController() {
        let diaryViewCoordinator = DiaryViewCoordinator(presenter: self.presenter, parent: self)
        self.add(child: diaryViewCoordinator)
        diaryViewCoordinator.start()
    }
}
