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
        let getMyIdUseCase = GetMyIdUseCase(userRepository: userRepository)
        let getUserUseCase = GetUserUseCase(userRepository: userRepository)
        let createUserUseCase = CreateUserUseCase(userRepository: userRepository)
        
        let viewModel = AuthenticationViewModel(
            sceneId: self.identifier,
            authenticateUseCase: authenticateUseCase,
            appleAuthProvider: appleAuthProvider,
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
            .sink { [weak self] _ in
                self?.agreementPageRequest()
            }
            .store(in: &self.cancellables)

        viewModel.pairingPageRequested
            .receive(on: DispatchQueue.main)
            .sink { [weak self] myId in
                self?.paringPageRequest(myId: myId)
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

    private func agreementPageRequest() {
        let agreementViewCoordinator = AgreementViewCoordinator(identifier: UUID(), presenter: self.presenter)
        self.children[identifier] = agreementViewCoordinator
        agreementViewCoordinator.start()
    }

    private func paringPageRequest(myId: DDID) {
        let user = User(id: myId)
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
