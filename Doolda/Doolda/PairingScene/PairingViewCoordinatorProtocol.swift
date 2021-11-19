//
//  PairingViewCoordinatorProtocol.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/03.
//

import Foundation

protocol PairingViewCoordinatorProtocol: CoordinatorProtocol {
    func userDidPaired(user: User)
}
