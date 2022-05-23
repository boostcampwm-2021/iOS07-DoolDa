//
//  AgreementViewCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/12/28.
//

import Combine
import UIKit

final class AgreementViewCoordinator: BaseCoordinator {
    
    // MARK: - Nested enum
    
    enum Notifications {
        static let userDidApproveApplicationServicePolicy = Notification.Name("userDidApproveApplicationServicePolicy")
    }
    
    enum Keys {
        static let myId = "myId"
    }

    private let user: User
    private var cancellables: Set<AnyCancellable> = []
    
    init(identifier: UUID, presenter: UINavigationController, user: User) {
        self.user = user
        super.init(identifier: identifier, presenter: presenter)
    }
    
    func start() {
        let userDefaultsPersistenceService = UserDefaultsPersistenceService.shared
        let firebaseNetworkService = FirebaseNetworkService.shared
        
        let userRepository = UserRepository(
            persistenceService: userDefaultsPersistenceService,
            networkService: firebaseNetworkService
        )
        
        let registerUserUseCase = RegisterUserUseCase(userRepository: userRepository)
        let agreementUseCase = AgreementUseCase(userRepository: userRepository)
        
        let viewModel = AgreementViewModel(
            user: self.user,
            sceneId: self.identifier,
            registerUserUseCase: registerUserUseCase,
            agreementUseCase: agreementUseCase
        )

        viewModel.pairingPageRequested.sink { [weak self] user in
            self?.userDidApproveApplicationServicePolicy(user: user)
        }
        .store(in: &self.cancellables)
        
        let viewController = AgreementViewController(viewModel: viewModel)
        self.presenter.pushViewController(viewController, animated: false)
    }

    
    private func userDidApproveApplicationServicePolicy(user: User) {
        let identifier = UUID()
        let paringViewCoordinator = PairingViewCoordinator(identifier: identifier, presenter: self.presenter, user: user)
        self.children[identifier] = paringViewCoordinator
        paringViewCoordinator.start()
    }
}
