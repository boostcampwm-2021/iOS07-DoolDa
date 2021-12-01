//
//  CoordinatorProtocol.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/08.
//

import UIKit

protocol CoordinatorProtocol {
    var identifier: UUID { get }
    var presenter: UINavigationController { get }
    var children: [UUID: CoordinatorProtocol] { get set }
    
    func start()
}
