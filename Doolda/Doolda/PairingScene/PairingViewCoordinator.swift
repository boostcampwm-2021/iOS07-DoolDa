//
//  ParingViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/02.
//

import Combine
import UIKit

class PairingViewCoordinator: BaseCoordinator {

    private let user: User
    private var cancellables: Set<AnyCancellable> = []
    
    init(identifier: UUID, presenter: UINavigationController, user: User) {
        self.user = user
        super.init(identifier: identifier, presenter: presenter)
    }
    
    func start() {
        let userDefaultsPersistenceService = UserDefaultsPersistenceService.shared
        let urlSessionNetworkService = URLSessionNetworkService.shared
        let firebaseNetworkService = FirebaseNetworkService.shared
        
        let userRepository = UserRepository(
            persistenceService: userDefaultsPersistenceService,
            networkService: firebaseNetworkService
        )
        
        let pairRepository = PairRepository(networkService: firebaseNetworkService)

        let pairUserUseCase = PairUserUseCase(userRepository: userRepository, pairRepository: pairRepository)
        let refreshUserUseCase = RefreshUserUseCase(userRepository: userRepository)
        let firebaseMessageUseCase = FirebaseMessageUseCase.default

        let viewModel = PairingViewModel(
            sceneId: self.identifier,
            user: user,
            pairUserUseCase: pairUserUseCase,
            refreshUserUseCase: refreshUserUseCase,
            firebaseMessageUseCase: firebaseMessageUseCase
        )
        
        viewModel.pairedUserPublisher
            .compactMap { $0 }
            .sink { [weak self] user in
                self?.userDidPaired(user: user)
            }
            .store(in: &self.cancellables)

        DispatchQueue.main.async {
            let viewController = PairingViewController(viewModel: viewModel)
            self.presenter.setViewControllers([viewController], animated: false)
        }
    }

    private func userDidPaired(user: User) {
        let identifier = UUID()
        let diaryViewCoordinator = DiaryViewCoordinator(identifier: identifier, presenter: self.presenter, user: user)
        self.children[identifier] = diaryViewCoordinator
        diaryViewCoordinator.start()
    }
}
