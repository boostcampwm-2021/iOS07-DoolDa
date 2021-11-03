//
//  SplashViewCoordinatorDelegate.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import Foundation

protocol SplashViewCoordinatorDelegate {
    func userNotPaired(myId: String)
    func userAlreadyPaired(myId: String, pairId: String)
}
