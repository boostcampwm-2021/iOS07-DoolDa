//
//  SignUpViewCoordinator.swift
//  Doolda
//
//  Created by minju kim on 2022/05/15.
//

import Combine
import UIKit

final class SignUpViewCoordinator: BaseCoordinator {

    // MARK: - Nested enum

    private var cancellables: Set<AnyCancellable> = []

    override init(identifier: UUID, presenter: UINavigationController) {
        super.init(identifier: identifier, presenter: presenter)
    }

    func start() {
        let signUpUseCase = SignUpUseCase()
        let userRepository = UserRepository(
            persistenceService: UserDefaultsPersistenceService.shared,
            networkService: FirebaseNetworkService.shared)
        let createUserUseCase = CreateUserUseCase(userRepository: userRepository)
        let viewModel = SignUpViewModel(
            signUpUseCase: signUpUseCase,
            createUserUseCase: createUserUseCase)

        viewModel.signInPageRequested.sink { [weak self] _ in
            self?.loginPageRequested()
        }
        .store(in: &self.cancellables)

        viewModel.agreementPageRequested.sink { [weak self] user in
            self?.agreementPageRequest(user: user)
        }
        .store(in: &self.cancellables)

        let viewController = SignUpViewController(viewModel: viewModel)
        self.presenter.pushViewController(viewController, animated: false)
    }

    private func loginPageRequested() {
        self.presenter.popViewController(animated: true)
    }

    private func agreementPageRequest(user: User) {
        let agreementViewCoordinator = AgreementViewCoordinator(identifier: UUID(), presenter: self.presenter, user: user)
        self.children[identifier] = agreementViewCoordinator
        agreementViewCoordinator.start()
    }
}
