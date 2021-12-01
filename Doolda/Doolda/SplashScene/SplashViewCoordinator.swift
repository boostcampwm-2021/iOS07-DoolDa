//
//  SplashViewCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import UIKit

final class SplashViewCoordinator: SplashViewCoordinatorProtocol {
    var identifier: UUID
    var presenter: UINavigationController
    var children: [UUID : CoordinatorProtocol] = [:]

    init(identifier: UUID, presenter: UINavigationController) {
        self.identifier = identifier
        self.presenter = presenter
    }
    
    func start() {
        let userDefaultsPersistenceService = UserDefaultsPersistenceService.shared
        let urlSessionNetworkService = URLSessionNetworkService.shared
        
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
        let identifier = UUID()
        let paringViewCoordinator = PairingViewCoordinator(identifier: identifier, presenter: self.presenter, user: user)
        self.children[identifier] = paringViewCoordinator
        paringViewCoordinator.start()
    }

    func userAlreadyPaired(user: User) {
        let identifier = UUID()
        let diaryViewCoordinator = DiaryViewCoordinator(identifier: identifier, presenter: self.presenter, user: user)
        self.children[identifier] = diaryViewCoordinator
        diaryViewCoordinator.start()
    }
}
