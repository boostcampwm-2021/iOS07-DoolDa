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
        let authenticationUseCase = AuthenticationUseCase()
        let viewModel = AuthenticationViewModel(sceneId: self.identifier, authenticationUseCase: authenticationUseCase)
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

    private func userDidSignIn() {
        // FIXME: 미구현
        print("Present Agreement ViewController")
    }
}

