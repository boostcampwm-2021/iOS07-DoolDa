//
//  SettingsViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/21.
//

import UIKit

class SettingsViewCoordinator: SettingsViewCoordinatorProtocol {
    var presenter: UINavigationController

    init(presenter: UINavigationController) {
        self.presenter = presenter
    }

    func start() {
        DispatchQueue.main.async {
            let userDefaultsPersistenceService = UserDefaultsPersistenceService()

            let globalFontRepository = GlobalFontRepository(persistenceService: userDefaultsPersistenceService)
            let pushNotificationStateRepository = PushNotificationStateRepository(persistenceService: userDefaultsPersistenceService)

            let globalFontUseCase = GlobalFontUseCase(globalFontRepository: globalFontRepository)
            let pushNotificationStateUseCase = PushNotificationStateUseCase(pushNotificationStateRepository: pushNotificationStateRepository)

            let viewModel = SettingsViewModel(
                coordinator: self,
                globalFontUseCase: globalFontUseCase,
                pushNotificationStateUseCase: pushNotificationStateUseCase
            )

            let viewController = SettingsViewController(viewModel: viewModel)
            self.presenter.pushViewController(viewController, animated: true)
        }
    }

    func settingsOptionRequested(title: String ,text: String) {
        let viewController = SettingsDetailedInfoViewController(title: title, content: text)
        self.presenter.topViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
}
