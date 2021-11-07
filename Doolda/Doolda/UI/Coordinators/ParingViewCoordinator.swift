//
//  ParingViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/02.
//

import UIKit

class PairingViewCoordinator: Coordinator {
    private let user: User
    
    init(presenter: UINavigationController, parent: Coordinator? = nil, user: User) {
        self.user = user
        super.init(presenter: presenter, parent: parent)
    }
    
    override func start() {
        let userDefaultsPersistenceService = UserDefaultsPersistenceService()
        let firebaseNetworkService = FirebaseNetworkService()
        
        let userRepository = UserRepository(
            persistenceService: userDefaultsPersistenceService,
            networkService: firebaseNetworkService
        )

        let pairUserUseCase = PairUserUseCase(userRepository: userRepository)
        let refreshUserUseCase = RefreshUserUseCase(userRepository: userRepository)

        let viewModel = PairingViewModel(
            user: user,
            coordinatorDelegate: self,
            pairUserUseCase: pairUserUseCase,
            refreshUserUseCase: refreshUserUseCase
        )
        
        let viewController = PairingViewController(viewModel: viewModel)
        self.presenter.setViewControllers([viewController], animated: false)
    }
}

extension PairingViewCoordinator: PairingViewCoordinatorDelegate {
    func userDidPaired(user: User) {
        let diaryViewCoordinator = DiaryViewCoordinator(presenter: self.presenter, parent: self, user: user)
        self.add(child: diaryViewCoordinator)
        diaryViewCoordinator.start()
    }
}
