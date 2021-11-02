//
//  SplashViewModel.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import Foundation

final class SplashViewModel {
    private let coordinatorDelegate: SplashViewCoordinatorDelegate
    
    init(coordinatorDelegate: SplashViewCoordinatorDelegate) {
        self.coordinatorDelegate = coordinatorDelegate
    }

    func IdDidLoad() {
        // 식별코드 모두 있다면 coordinatorDelegate.presentDiaryViewController
        // 없다면 coordinatorDelegate.presentParingViewController
    }
}
