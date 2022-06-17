//
//  AppCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import Combine
import UIKit

final class AppCoordinator: BaseCoordinator {
    
    // MARK: - Nested enum
    
    enum Notifications {
        static let coordinatorDidPop = Notification.Name("coordinatorDidPop")
        static let appRestartSignal = Notification.Name("appRestartSignal")
        static let loginDuplicatePopup = Notification.Name("loginDuplicatePopup")
    }
    
    enum Keys {
        static let coordinatorIdentifier = "coordinatorIdentifier"
    }

    private var cancellables: Set<AnyCancellable> = []
    
    override init(identifier: UUID = UUID(), presenter: UINavigationController) {
        super.init(identifier: identifier, presenter: presenter)
        self.bind()
    }
    
    private func bind() {
        NotificationCenter.default.publisher(for: Notifications.coordinatorDidPop, object: nil)
            .compactMap { $0.userInfo?[Keys.coordinatorIdentifier] as? UUID }
            .sink { [weak self] identifier in
                self?.children.removeValue(forKey: identifier)
            }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: Notifications.appRestartSignal, object: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.children.removeAll()
                self?.presenter.children.forEach { $0.removeFromParent() }
                self?.start()
            }
            .store(in: &self.cancellables)

        NotificationCenter.default.publisher(for: Notifications.loginDuplicatePopup, object: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                let visibleViewController = self.presenter.visibleViewController
                let alert = UIAlertController.defaultAlert(title: "알림",
                                                           message: "다른 기기에서 로그인 하였습니다. 현재 기기에서 로그아웃 됩니다.",
                                                           handler: { [weak self] _ in
                    self?.children.removeAll()
                    self?.presenter.children.forEach { $0.removeFromParent() }
                    self?.start()
                })
                visibleViewController?.present(alert, animated: true)
            }
            .store(in: &self.cancellables)
    }
    
    func start() {
        let splashIdentifier = UUID()
        let splashViewCoordinator = SplashViewCoordinator(identifier: splashIdentifier, presenter: self.presenter)
        self.children[splashIdentifier] = splashViewCoordinator
        splashViewCoordinator.start()
    }
}
