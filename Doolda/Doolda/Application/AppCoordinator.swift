//
//  AppCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import Combine
import UIKit

final class AppCoordinator: CoordinatorProtocol {
    var identifier: UUID
    var presenter: UINavigationController
    var children: [UUID: CoordinatorProtocol] = [:]

    private var cancellables: Set<AnyCancellable> = []
    
    init(identifier: UUID = UUID(), presenter: UINavigationController) {
        self.identifier = identifier
        self.presenter = presenter
        self.bind()
    }
    
    private func bind() {
        NotificationCenter.default.publisher(for: PushMessageEntity.Notifications.userDisconnected, object: nil)
            .sink { [weak self] _ in
                self?.start()
            }
            .store(in: &self.cancellables)
        
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
    }
    
    func start() {
        let splashIdentifier = UUID()
        let splashViewCoordinator = SplashViewCoordinator(identifier: splashIdentifier, presenter: self.presenter)
        self.children[splashIdentifier] = splashViewCoordinator
        splashViewCoordinator.start()
    }
    
    enum Notifications {
        static let coordinatorDidPop = Notification.Name("coordinatorDidPop")
        static let appRestartSignal = Notification.Name("appRestartSignal")
    }
    
    enum Keys {
        static let coordinatorIdentifier = "coordinatorIdentifier"
    }
    
}
