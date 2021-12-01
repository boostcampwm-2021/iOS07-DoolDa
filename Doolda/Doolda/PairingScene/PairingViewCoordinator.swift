//
//  ParingViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/02.
//

import Combine
import UIKit

class PairingViewCoordinator: BaseCoordinator {
    
    // MARK: - Nested enum
    
    enum Notifications {
        static let userDidPaired = Notification.Name("userDidPaired")
    }
    
    enum Keys {
        static let user = "user"
    }
    
    private let user: User

    private var cancellables: Set<AnyCancellable> = []
    
    init(identifier: UUID, presenter: UINavigationController, user: User) {
        self.user = user
        super.init(identifier: identifier, presenter: presenter)
        self.bind()
    }
    
    func start() {
        let userDefaultsPersistenceService = UserDefaultsPersistenceService.shared
        let urlSessionNetworkService = URLSessionNetworkService.shared
        
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
            sceneId: self.identifier,
            user: user,
            pairUserUseCase: pairUserUseCase,
            refreshUserUseCase: refreshUserUseCase,
            firebaseMessageUseCase: firebaseMessageUseCase
        )

        DispatchQueue.main.async {
            let viewController = PairingViewController(viewModel: viewModel)
            self.presenter.setViewControllers([viewController], animated: false)
        }
    }
    
    private func bind() {
        NotificationCenter.default.publisher(for: Notifications.userDidPaired, object: nil)
            .receive(on: DispatchQueue.main)
            .compactMap { $0.userInfo?[Keys.user] as? User }
            .sink { [weak self] user in
                self?.userDidPaired(user: user)
            }
            .store(in: &self.cancellables)
    }
    
    private func userDidPaired(user: User) {
        let identifier = UUID()
        let diaryViewCoordinator = DiaryViewCoordinator(identifier: identifier, presenter: self.presenter, user: user)
        self.children[identifier] = diaryViewCoordinator
        diaryViewCoordinator.start()
    }
}
