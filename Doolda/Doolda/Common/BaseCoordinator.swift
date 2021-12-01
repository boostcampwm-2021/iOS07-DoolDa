//
//  BaseCoordinator.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/08.
//

import Combine
import UIKit

class BaseCoordinator {
    
    // MARK: - Nested Enums
    
    enum Notifications {
        static let coordinatorRemoveFromParent = Notification.Name("coordinatorRemoveFromParent")
    }
    
    enum Keys {
        static let sceneId = "sceneId"
    }
    
    var identifier: UUID
    var presenter: UINavigationController
    var children: [UUID: BaseCoordinator] = [:]
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(identifier: UUID, presenter: UINavigationController) {
        self.identifier = identifier
        self.presenter = presenter
        self.bindRemoveRequest()
    }
    
    func bindRemoveRequest() {
        NotificationCenter.default.publisher(for: Notifications.coordinatorRemoveFromParent, object: nil)
            .compactMap { $0.userInfo?[Keys.sceneId] as? UUID }
            .filter { [weak self] identifier in
                guard let self = self else { return false }
                return self.children.contains { $0.key == identifier }
            }
            .sink { [weak self] identifier in self?.children.removeValue(forKey: identifier) }
            .store(in: &self.cancellables)
    }
}
