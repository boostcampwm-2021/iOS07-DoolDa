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

    private var cancellables: Set<AnyCancellable> = []

    override init(identifier: UUID, presenter: UINavigationController) {
        super.init(identifier: identifier, presenter: presenter)
    }

    func start() {
        let userDefaultService = UserDefaultsPersistenceService.shared
        let networkService = FirebaseNetworkService.shared
        
        let userRepository = UserRepository(persistenceService: userDefaultService, networkService: networkService)
        
        let authenticateUseCase = AuthenticateUseCase()
        let appleAuthProvider = AppleAuthProvideUseCase()
        let deviceUseCase = DeviceUseCase()
        let getMyIdUseCase = GetMyIdUseCase(userRepository: userRepository)
        let getUserUseCase = GetUserUseCase(userRepository: userRepository)
        let createUserUseCase = CreateUserUseCase(userRepository: userRepository)
        
        let viewModel = AuthenticationViewModel(
            sceneId: self.identifier,
            authenticateUseCase: authenticateUseCase,
            appleAuthProvider: appleAuthProvider,
            deviceUseCase: deviceUseCase,
            getMyIdUseCase: getMyIdUseCase,
            getUserUseCase: getUserUseCase,
            createUserUseCase: createUserUseCase
        )
        
        viewModel.signUpPageRequested
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.signUpPageRequest()
            }
            .store(in: &self.cancellables)

        viewModel.agreementPageRequested
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.agreementPageRequest(user: user)
            }
            .store(in: &self.cancellables)

        viewModel.pairingPageRequested
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.paringPageRequest(user: user)
            }
            .store(in: &self.cancellables)

        viewModel.diaryPageRequested
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.diaryPageRequest(user: user)
            }
            .store(in: &self.cancellables)
        
        let viewController = AuthenticationViewController(viewModel: viewModel)
        self.presenter.pushViewController(viewController, animated: false)
    }

    private func signUpPageRequest() {
        let identifier = UUID()
        let signUpViewCoordinator = SignUpViewCoordinator(identifier: identifier, presenter: self.presenter)
        self.children[identifier] = signUpViewCoordinator
        signUpViewCoordinator.start()
    }

    private func agreementPageRequest(user: User) {
        let identifier =  UUID()
        let agreementViewCoordinator = AgreementViewCoordinator(identifier: identifier, presenter: self.presenter, user: user)
        self.children[identifier] = agreementViewCoordinator
        agreementViewCoordinator.start()
    }

    private func paringPageRequest(user: User) {
        let identifier = UUID()
        let paringViewCoordinator = PairingViewCoordinator(identifier: identifier, presenter: self.presenter, user: user)
        self.children[identifier] = paringViewCoordinator
        paringViewCoordinator.start()
    }

    private func diaryPageRequest(user: User) {
        let identifier = UUID()
        let diaryViewCoordinator = DiaryViewCoordinator(identifier: identifier, presenter: self.presenter, user: user)
        self.children[identifier] = diaryViewCoordinator
        diaryViewCoordinator.start()
    }
}
