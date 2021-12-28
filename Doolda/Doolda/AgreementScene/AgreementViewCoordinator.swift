//
//  AgreementViewCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/12/28.
//

import Combine
import UIKit

final class AgreementViewCoordinator: BaseCoordinator {
    
    //MARK: - Nested enum
    
    enum Notifications {
        static let userDidApproveApplicationServicePolicy = Notification.Name("userDidApproveApplicationServicePolicy")
    }
    
    enum Keys {
        static let myId = "myId"
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    override init(identifier: UUID, presenter: UINavigationController) {
        super.init(identifier: identifier, presenter: presenter)
        self.bind()
    }
    
    func start() {
        let userDefaultsPersistenceService = UserDefaultsPersistenceService.shared
        let urlSessionNetworkService = URLSessionNetworkService.shared
        
        let userRespository = UserRepository(
            persistenceService: userDefaultsPersistenceService,
            networkService: urlSessionNetworkService
        )
        
        let registerUserUseCase = RegisterUserUseCase(userRepository: userRespository)
        
        let viewModel = AgreementViewModel(sceneId: self.identifier, registerUserUseCase: registerUserUseCase)
        
        let viewController = AgreementViewController(viewModel: viewModel)
        self.presenter.pushViewController(viewController, animated: false)
    }
    
    private func bind() {
        NotificationCenter.default.publisher(for: Notifications.userDidApproveApplicationServicePolicy, object: nil)
            .receive(on: DispatchQueue.main)
            .compactMap { $0.userInfo?[Keys.myId] as? DDID }
            .sink { [weak self] myId in
                self?.userDidApproveApplicationServicePolicy(myId: myId)
            }
            .store(in: &self.cancellables)
    }
    
    private func userDidApproveApplicationServicePolicy(myId: DDID) {
        let user = User(id: myId)
        let identifier = UUID()
        let paringViewCoordinator = PairingViewCoordinator(identifier: identifier, presenter: self.presenter, user: user)
        self.children[identifier] = paringViewCoordinator
        paringViewCoordinator.start()
    }
}
