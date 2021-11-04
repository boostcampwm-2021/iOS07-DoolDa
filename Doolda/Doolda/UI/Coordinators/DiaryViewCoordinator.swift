//
//  DiaryViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/02.
//

import UIKit

class DiaryViewCoordinator: Coordinator {
    private let myId: String
    private let pairId: String
    
    init(presenter: UINavigationController, parent: Coordinator? = nil, myId: String, pairId: String) {
        self.myId = myId
        self.pairId = pairId
        super.init(presenter: presenter, parent: parent)
    }
    
    override func start() {
        let viewController = DiaryViewController()
        self.presenter.setViewControllers([viewController], animated: false)
    }
}
