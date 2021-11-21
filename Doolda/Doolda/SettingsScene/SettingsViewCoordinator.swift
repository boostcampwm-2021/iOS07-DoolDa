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
            let viewController = SettingsViewController()
            self.presenter.pushViewController(viewController, animated: true)
        }
    }
}
