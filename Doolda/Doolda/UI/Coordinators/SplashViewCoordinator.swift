//
//  SplashViewCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import UIKit

class SplashViewCoordinator: Coordinator {
    override func start() {
        let userDefaultsPersistenceService = UserDefaultsPersistenceService()
        let firebaseNetworkService = FirebaseNetworkService()
        
        let userRespository = UserRepository(
            persistenceService: userDefaultsPersistenceService,
            networkService: firebaseNetworkService
        )
        
        let getMyIdUseCase = GetMyIdUseCase(userRepository: userRespository)
        let getUserUseCase = GetUserUseCase(userRepository: userRespository)
        let registerUserUseCase = RegisterUserUseCase(userRepository: userRespository)
        
        let viewModel = SplashViewModel(
            coordinatorDelegate: self,
            getMyIdUseCase: getMyIdUseCase,
            getUserUseCase: getUserUseCase,
            registerUserUseCase: registerUserUseCase
        )
        
        let viewController = SplashViewController(viewModel: viewModel)
        self.presenter.pushViewController(viewController, animated: false)
    }
}

extension SplashViewCoordinator: SplashViewCoordinatorDelegate {
    func userNotPaired(myId: DDID) {
        let user = User(id: myId)
        let paringViewCoordinator = PairingViewCoordinator(presenter: self.presenter, parent: self, user: user)
        self.add(child: paringViewCoordinator)
        paringViewCoordinator.start()
    }

    func userAlreadyPaired(user: User) {
        let diaryViewCoordinator = DiaryViewCoordinator(presenter: self.presenter, parent: self, user: user)
        self.add(child: diaryViewCoordinator)
        diaryViewCoordinator.start()
    }
}
