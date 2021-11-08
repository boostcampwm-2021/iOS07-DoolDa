//
//  AppCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import UIKit

final class AppCoordinator: CoordinatorProtocol {
    var presenter: UINavigationController
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func start() {
        let splashViewCoordinator = SplashViewCoordinator(presenter: self.presenter)
        splashViewCoordinator.start()
    }
}
