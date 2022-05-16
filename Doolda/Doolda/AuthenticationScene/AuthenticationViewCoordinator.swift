//
//  AuthenticationViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2022/03/30.
//

import Combine
import Foundation
import UIKit

final class AuthenticationViewCoordinator: BaseCoordinator {

    // MARK: - Nested enum

    enum Notifications {
        static let userDidSignIn = Notification.Name("userDidSignIn")
    }

    private var cancellables: Set<AnyCancellable> = []

    override init(identifier: UUID, presenter: UINavigationController) {
        super.init(identifier: identifier, presenter: presenter)
        self.bind()
    }

    func start() {
        let userDefaultService = UserDefaultsPersistenceService.shared
        let networkService = FirebaseNetworkService.shared
        
        let userRepository = UserRepository(persistenceService: userDefaultService, networkService: networkService)
        
        let authenticateUseCase = AuthenticateUseCase()
        let appleAuthProvider = AppleAuthProvideUseCase()
        let getMyIdUseCase = GetMyIdUseCase(userRepository: userRepository)
        let getUserUseCase = GetUserUseCase(userRepository: userRepository)
        let createUserUseCase = CreateUserUseCase()
        
        let viewModel = AuthenticationViewModel(
            sceneId: self.identifier,
            authenticateUseCase: authenticateUseCase,
            appleAuthProvider: appleAuthProvider,
            getMyIdUseCase: getMyIdUseCase,
            getUserUseCase: getUserUseCase,
            createUserUseCase: createUserUseCase
        )
        
        // TODO: [주민] Coordinator 구현 ViewModel과 연결하시오
        
        let viewController = AuthenticationViewController(viewModel: viewModel)
        self.presenter.pushViewController(viewController, animated: false)
    }

    private func bind() {
        NotificationCenter.default.publisher(for: Notifications.userDidSignIn, object: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.userDidSignIn()
            }
            .store(in: &self.cancellables)
    }

    private func signUpPageRequest() {
        let identifier = UUID()
        let signUpViewCoordinator = SignUpViewCoordinator(identifier: identifier, presenter: self.presenter)
        self.children[identifier] = signUpViewCoordinator
        signUpViewCoordinator.start()
    }

    private func userDidSignIn() {
        print("Present Agreement ViewController")
    }
}
