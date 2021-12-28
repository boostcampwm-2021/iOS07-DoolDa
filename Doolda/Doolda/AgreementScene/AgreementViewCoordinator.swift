//
//  AgreementViewCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/12/28.
//

import Combine
import UIKit

final class AgreementViewCoordinator: BaseCoordinator {
    
    //MARK: - Nested enum
    
    enum Notifications {
        static let userDidApproveApplicationServicePolicy = Notification.Name("userDidApproveApplicationServicePolicy")
    }
    
    enum Keys {
        static let myId = "myId"
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    override init(identifier: UUID, presenter: UINavigationController) {
        super.init(identifier: identifier, presenter: presenter)
    }
}
