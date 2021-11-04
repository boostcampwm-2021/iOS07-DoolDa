//
//  SplashViewCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import UIKit

class SplashViewCoordinator: Coordinator {
    override func start() {
        let userRespository = UserRepository(persistenceService: UserDefaultsPersistenceService(),
                                             networkService: FirebaseNetworkService())
        let getMyIdUseCase = GetMyIdUseCase(userRepository: userRespository)
        let getPairIdUseCase = GetPairIdUseCase(userRepository: userRespository)
        let generateMyIdUseCase = GenerateMyIdUseCase(userRepository: userRespository)
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
