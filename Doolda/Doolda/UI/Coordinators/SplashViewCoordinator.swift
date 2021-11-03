//
//  SplashViewCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import UIKit

class SplashViewCoordinator: Coordinator {
    func start() {
        let getMyIdUseCase = MockGetMyIdUseCase()
        let getPairIdUseCase = GetPairIdUseCase()
        let generateMyIdUseCase = GenerateMyIdUseCase()
        let viewModel = SplashViewModel(coordinatorDelegate: self,
                                        getMyIdUseCase: getMyIdUseCase,
                                        getPairIdUseCase: getPairIdUseCase,
                                        generateMyIdUseCase: generateMyIdUseCase)
        let viewController = SplashViewController(viewModel: viewModel)
        self.presenter.pushViewController(viewController, animated: false)
    }
}

extension SplashViewCoordinator: SplashViewCoordinatorDelegate {
    func userNotPaired(myId: String) {
        let paringViewCoordinator = PairingViewCoordinator(presenter: self.presenter, parent: self, myId: myId)
        self.add(child: paringViewCoordinator)
        paringViewCoordinator.start()
    }

    func userAlreadyPaired(myId: String, pairId: String) {
        let diaryViewCoordinator = DiaryViewCoordinator(presenter: self.presenter, parent: self, myId: myId, pairId: pairId)
        self.add(child: diaryViewCoordinator)
        diaryViewCoordinator.start()
    }
}
