//
//  SplashViewModel.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import Foundation

import Combine

final class SplashViewModel {

    @Published var myId: UUID?
    @Published var pairId: UUID?

    private let coordinatorDelegate: SplashViewCoordinatorDelegate
    
    init(coordinatorDelegate: SplashViewCoordinatorDelegate) {
        self.coordinatorDelegate = coordinatorDelegate
    }

    func idDidLoad() {
        // 식별코드 모두 있다면 coordinatorDelegate.presentDiaryViewController
        // 없다면 coordinatorDelegate.presentParingViewController
        coordinatorDelegate.presentParingViewController()

    }
}
