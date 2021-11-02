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
        // ParingViewCoordinator 생성
        // parent, child 설정
    }

    func presentDiaryViewController() {
        // DiaryViewCoordinator 생성
        // parent, child 설정
    }
}
