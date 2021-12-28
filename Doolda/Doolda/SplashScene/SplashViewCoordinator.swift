//
//  SplashViewCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import Combine
import UIKit

final class SplashViewCoordinator: BaseCoordinator {
    
    // MARK: - Nested enum
    
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
        self.bind()
    }
    
    func start() {
        let userDefaultsPersistenceService = UserDefaultsPersistenceService.shared
        let urlSessionNetworkService = URLSessionNetworkService.shared
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

        let viewController = SplashViewController(viewModel: viewModel)
        self.presenter.pushViewController(viewController, animated: false)
    }
    
    private func bind() {
        NotificationCenter.default.publisher(for: Notifications.userNotLoggedIn, object: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.userNotLoggedIn()
            }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: Notifications.userNotExists, object: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.userNotExists()
            }
            .store(in: &self.cancellables)
        
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
    
    // FIXME: NOT IMPLEMENTED
    private func userNotLoggedIn() {
        // let identifier = UUID()
        // let authenticationViewCoordinator = AuthenticationViewCoordinator()
        // self.children[identifier] = authenticationViewCoordinator
        // authenticationViewCoordinator.start()
    }
    
    // FIXME: NOT IMPLEMENTED
    private func userNotExists() {
        // let identifier = UUID()
        // let agreementViewCoordinator = AgreementViewCoordinator()
        // self.children[identifier] = agreementViewCoordinator
        // agreementViewCoordinator.start()
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
