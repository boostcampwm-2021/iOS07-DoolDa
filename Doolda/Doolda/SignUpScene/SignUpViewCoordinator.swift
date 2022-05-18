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
        let singUpUseCase = SignUpUseCase()
        let viewModel = SignUpViewModel(signUpUseCase: singUpUseCase)

        viewModel.signInPageRequested.sink { [weak self] _ in
            self?.loginPageRequested()
        }
        .store(in: &self.cancellables)

        let viewController = SignUpViewController(viewModel: viewModel)
        self.presenter.pushViewController(viewController, animated: false)
    }

    private func loginPageRequested() {
        self.presenter.popViewController(animated: true)
    }
}
