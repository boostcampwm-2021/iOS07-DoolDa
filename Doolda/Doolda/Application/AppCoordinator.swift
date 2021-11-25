//
//  AppCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import Combine
import UIKit

final class AppCoordinator: CoordinatorProtocol {
    var presenter: UINavigationController
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
        self.bind()
    }
    
    private func bind() {
        NotificationCenter.default.publisher(for: PushMessageEntity.Notifications.userDisconnected, object: nil)
            .sink { [weak self] _ in
                self?.start()
            }
            .store(in: &self.cancellables)
    }
    
    func start() {
        let splashViewCoordinator = SplashViewCoordinator(presenter: self.presenter)
        splashViewCoordinator.start()
    }
}
