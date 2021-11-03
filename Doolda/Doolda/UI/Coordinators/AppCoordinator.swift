//
//  AppCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import UIKit

final class AppCoordinator: Coordinator {
    override func start() {
        let splashViewCoordinator = SplashViewCoordinator(presenter: self.presenter, parent: self)
        self.add(child: splashViewCoordinator)
        splashViewCoordinator.start()
    }
}
