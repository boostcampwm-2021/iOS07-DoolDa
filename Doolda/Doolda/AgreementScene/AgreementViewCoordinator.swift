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
    }
    
    func start() {
        let userDefaultsPersistenceService = UserDefaultsPersistenceService.shared
        let urlSessionNetworkService = URLSessionNetworkService.shared
        
        let userRespository = UserRepository(
            persistenceService: userDefaultsPersistenceService,
            networkService: urlSessionNetworkService
        )
        
        let registerUserUseCase = RegisterUserUseCase(userRepository: userRespository)
        
        // FIXME: ViewModel, ViewController 생성 및 화면 전환
    }
}
