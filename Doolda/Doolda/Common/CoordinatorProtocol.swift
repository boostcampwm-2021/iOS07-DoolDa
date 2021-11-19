//
//  CoordinatorProtocol.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/08.
//

import UIKit

protocol CoordinatorProtocol {
    var presenter: UINavigationController { get }
    
    func start()
}
