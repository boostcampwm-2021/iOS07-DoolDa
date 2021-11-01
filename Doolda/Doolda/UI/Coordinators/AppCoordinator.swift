//
//  AppCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import UIKit

final class AppCoordinator: Coordinator {
    func start() {
        let coordinator = SplashViewCoordinator(presenter: self.presenter, parent: self)
        self.add(child: coordinator)
        coordinator.start()
    }
}
