//
//  Coordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import UIKit

class Coordinator {
    private var parent: Coordinator?
    private var children: [Coordinator] = []
    let presenter: UINavigationController
    
    init(presenter: UINavigationController, parent: Coordinator? = nil) {
        self.presenter = presenter
        self.parent = parent
    }
    
    func add(child: Coordinator) {
        self.children.append(child)
    }
    
    func removeFromParent() {
        guard let parent = parent else { return }
        parent.children = parent.children.filter { $0 != self }
    }
    
    func start() {
        fatalError("start method should be implemented")
    }
}

extension Coordinator: Equatable {
    static func == (lhs: Coordinator, rhs: Coordinator) -> Bool {
        return lhs === rhs
    }
}
