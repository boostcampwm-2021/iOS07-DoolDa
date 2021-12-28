//
//  AuthenticationViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/12/28.
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

    }

    private func bind() {

    }

    private func userDidSignIn() {
        
    }
}
