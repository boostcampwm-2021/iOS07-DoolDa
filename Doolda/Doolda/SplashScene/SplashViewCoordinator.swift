//
//  SplashViewCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import UIKit

class SplashViewCoordinator: SplashViewCoordinatorProtocol {
    var presenter: UINavigationController
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func start() {
        let userDefaultsPersistenceService = UserDefaultsPersistenceService()
        let urlSessionNetworkService = URLSessionNetworkService()
        
        let userRespository = UserRepository(
            persistenceService: userDefaultsPersistenceService,
            networkService: urlSessionNetworkService
        )
        let globalFontRepository = GlobalFontRepository(
            persistenceService: userDefaultsPersistenceService
        )
        
        let getMyIdUseCase = GetMyIdUseCase(userRepository: userRespository)
        let getUserUseCase = GetUserUseCase(userRepository: userRespository)
        let registerUserUseCase = RegisterUserUseCase(userRepository: userRespository)
        let globalFontUseCase = GlobalFontUseCase(globalFontRepository: globalFontRepository)
        
        let viewModel = SplashViewModel(
            coordinator: self,
            getMyIdUseCase: getMyIdUseCase,
            getUserUseCase: getUserUseCase,
            registerUserUseCase: registerUserUseCase,
            globalFontUseCase: globalFontUseCase
        )

        DispatchQueue.main.async {
            let viewController = SplashViewController(viewModel: viewModel)
            self.presenter.pushViewController(viewController, animated: false)
        }
    }
    
    func userNotPaired(myId: DDID) {
        let user = User(id: myId)
        let paringViewCoordinator = PairingViewCoordinator(presenter: self.presenter, user: user)
        paringViewCoordinator.start()
    }

    func userAlreadyPaired(user: User) {
        // FIXME : should change to diaryViewController
        let diaryViewCoordinator = DiaryViewCoordinator(presenter: self.presenter, user: user)
        diaryViewCoordinator.start()
//        let editPageViewCoordinator = EditPageViewCoordinator(presenter: self.presenter, user: user)
//        editPageViewCoordinator.start()
    }
}
