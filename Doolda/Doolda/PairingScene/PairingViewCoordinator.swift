//
//  ParingViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/02.
//

import UIKit

class PairingViewCoordinator: PairingViewCoordinatorProtocol {
    var presenter: UINavigationController
    private let user: User
    
    init(presenter: UINavigationController, user: User) {
        self.presenter = presenter
        self.user = user
    }
    
    func start() {
        let userDefaultsPersistenceService = UserDefaultsPersistenceService()
        let urlSessionNetworkService = URLSessionNetworkService()
        
        let userRepository = UserRepository(
            persistenceService: userDefaultsPersistenceService,
            networkService: urlSessionNetworkService
        )
        
        let pairRepository = PairRepository(networkService: urlSessionNetworkService)
        let fcmTokenRepository = FCMTokenRepository(urlSessionNetworkService: urlSessionNetworkService)
        let firebaseMessageRepository = FirebaseMessageRepository(urlSessionNetworkService: urlSessionNetworkService)

        let pairUserUseCase = PairUserUseCase(userRepository: userRepository, pairRepository: pairRepository)
        let refreshUserUseCase = RefreshUserUseCase(userRepository: userRepository)
        let firebaseMessageUseCase = FirebaseMessageUseCase(
            fcmTokenRepository: fcmTokenRepository,
            firebaseMessageRepository: firebaseMessageRepository
        )

        let viewModel = PairingViewModel(
            user: user,
            coordinator: self,
            pairUserUseCase: pairUserUseCase,
            refreshUserUseCase: refreshUserUseCase,
            firebaseMessageUseCase: firebaseMessageUseCase
        )

        DispatchQueue.main.async {
            let viewController = PairingViewController(viewModel: viewModel)
            self.presenter.setViewControllers([viewController], animated: false)
        }
    }
    
    func userDidPaired(user: User) {
        let diaryViewCoordinator = DiaryViewCoordinator(presenter: self.presenter, user: user)
        diaryViewCoordinator.start()
    }
}
