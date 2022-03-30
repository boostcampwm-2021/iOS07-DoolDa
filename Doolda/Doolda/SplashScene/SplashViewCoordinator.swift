//
//  SplashViewCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import Combine
import UIKit

final class SplashViewCoordinator: BaseCoordinator {
    
    //MARK: - Nested enum

    enum Notifications {
        static let userNotLoggedIn = Notification.Name("userNotLoggedIn")
        static let userNotExists = Notification.Name("userNotExists")
        static let userNotPaired = Notification.Name("userNotPaired")
        static let userAlreadyPaired = Notification.Name("userAlreadyPaired")
    }
    
    enum Keys {
        static let user = "user"
        static let myId = "myId"
    }
    
    private var cancellables: Set<AnyCancellable> = []

    override init(identifier: UUID, presenter: UINavigationController) {
        super.init(identifier: identifier, presenter: presenter)
    }
    
    func start() {
        let userDefaultsPersistenceService = UserDefaultsPersistenceService.shared
        let firebaseNetworkService = FirebaseNetworkService.shared

        let userRespository = UserRepository(
            persistenceService: userDefaultsPersistenceService,
            networkService: firebaseNetworkService
        )
        let globalFontRepository = GlobalFontRepository(
            persistenceService: userDefaultsPersistenceService
        )
        
        let authenticationUseCase = AuthenticationUseCase()
        let getMyIdUseCase = GetMyIdUseCase(userRepository: userRespository)
        let getUserUseCase = GetUserUseCase(userRepository: userRespository)
        let globalFontUseCase = GlobalFontUseCase(globalFontRepository: globalFontRepository)
        
        let viewModel = SplashViewModel(
            sceneId: self.identifier,
            authenticationUseCase: authenticationUseCase,
            getMyIdUseCase: getMyIdUseCase,
            getUserUseCase: getUserUseCase,
            globalFontUseCase: globalFontUseCase
        )
        
        viewModel.$user
            .compactMap { $0 }
            .sink (receiveValue: {[weak self] user in
                if user.pairId?.ddidString.isEmpty == false {
                    self?.userAlreadyPaired(user: user)
                } else {
                    self?.userNotPaired(myId: user.id)
                }
            })
            .store(in: &self.cancellables)

        let viewController = SplashViewController(viewModel: viewModel)
        self.presenter.pushViewController(viewController, animated: false)
    }
    
    private func userNotPaired(myId: DDID) {
        let user = User(id: myId)
        let identifier = UUID()
        let paringViewCoordinator = PairingViewCoordinator(identifier: identifier, presenter: self.presenter, user: user)
        self.children[identifier] = paringViewCoordinator
        paringViewCoordinator.start()
    }

    private func userAlreadyPaired(user: User) {
        let identifier = UUID()
        let diaryViewCoordinator = DiaryViewCoordinator(identifier: identifier, presenter: self.presenter, user: user)
        self.children[identifier] = diaryViewCoordinator
        diaryViewCoordinator.start()
    }
}
