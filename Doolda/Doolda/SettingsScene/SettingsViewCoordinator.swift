//
//  SettingsViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/21.
//

import UIKit

class SettingsViewCoordinator: SettingsViewCoordinatorProtocol {
    var presenter: UINavigationController
    private let user: User

    init(presenter: UINavigationController, user: User) {
        self.presenter = presenter
        self.user = user
    }

    func start() {
        DispatchQueue.main.async {
            let userDefaultsPersistenceService = UserDefaultsPersistenceService()
            let urlSessionNetworkService = URLSessionNetworkService()

            let globalFontRepository = GlobalFontRepository(persistenceService: userDefaultsPersistenceService)
            let pushNotificationStateRepository = PushNotificationStateRepository(persistenceService: userDefaultsPersistenceService)
            let userRepository = UserRepository(
                persistenceService: userDefaultsPersistenceService,
                networkService: urlSessionNetworkService
            )
            let pairRepository = PairRepository(networkService: urlSessionNetworkService)
            let fcmTokenRepository = FCMTokenRepository(urlSessionNetworkService: urlSessionNetworkService)
            let firebaseMessageRepository = FirebaseMessageRepository(urlSessionNetworkService: urlSessionNetworkService)

            let globalFontUseCase = GlobalFontUseCase(globalFontRepository: globalFontRepository)
            let pushNotificationStateUseCase = PushNotificationStateUseCase(pushNotificationStateRepository: pushNotificationStateRepository)
            let unpairUserUseCase = UnpairUserUseCase(userRepository: userRepository, pairRepository: pairRepository)
            let firebaseMessageUseCase = FirebaseMessageUseCase(
                fcmTokenRepository: fcmTokenRepository,
                firebaseMessageRepository: firebaseMessageRepository
            )

            let viewModel = SettingsViewModel(
                user: self.user,
                coordinator: self,
                globalFontUseCase: globalFontUseCase,
                unpairUserUseCase: unpairUserUseCase,
                pushNotificationStateUseCase: pushNotificationStateUseCase,
                firebaseMessageUseCase: firebaseMessageUseCase
            )
            let viewController = SettingsViewController(viewModel: viewModel)
            self.presenter.pushViewController(viewController, animated: true)
        }
    }

    func fontPickerSheetRequested() {
        guard let settingsViewController = self.presenter.topViewController as? SettingsViewController else { return }
        let fontPickerSheet = FontPickerViewController(delegate: settingsViewController)
        settingsViewController.present(fontPickerSheet, animated: false, completion: nil)
    }

    func settingsOptionRequested(title: String ,text: String) {
        let viewController = SettingsDetailedInfoViewController()
        viewController.titleText = title
        viewController.contentText = text
        self.presenter.topViewController?.navigationController?.pushViewController(viewController, animated: true)
    }

    func splashViewRequested() {
        let coordinator = SplashViewCoordinator(presenter: self.presenter)
        coordinator.start()
    }
}
