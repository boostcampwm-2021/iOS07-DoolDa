//
//  SplashViewCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import Combine
import UIKit

final class SplashViewCoordinator: CoordinatorProtocol {
    
    //MARK: - Nested enum
    
    enum Notifications {
        static let userNotPaired = Notification.Name("userNotPaired")
        static let userAlreadyPaired = Notification.Name("userAlreadyPaired")
    }
    
    enum Keys {
        static let user = "user"
        static let myId = "myId"
    }
    
    var identifier: UUID
    var presenter: UINavigationController
    var children: [UUID : CoordinatorProtocol] = [:]
    
    private var cancellables: Set<AnyCancellable> = []

    init(identifier: UUID, presenter: UINavigationController) {
        self.identifier = identifier
        self.presenter = presenter
        self.bind()
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
    
    private func bind() {
        NotificationCenter.default.publisher(for: Notifications.userNotPaired, object: nil)
            .receive(on: DispatchQueue.main)
            .compactMap { $0.userInfo?[Keys.myId] as? DDID }
            .sink { [weak self] myId in
                self?.userNotPaired(myId: myId)
            }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: Notifications.userAlreadyPaired, object: nil)
            .receive(on: DispatchQueue.main)
            .compactMap { $0.userInfo?[Keys.user] as? User }
            .sink { [weak self] user in
                self?.userAlreadyPaired(user: user)
            }
            .store(in: &self.cancellables)
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
