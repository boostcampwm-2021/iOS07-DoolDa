//
//  PushNotificationStateRepositoryProtocol.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/16.
//

import Foundation

protocol PushNotificationStateRepositoryProtocol {
    func saveState(as state: Bool)
    func fetchState() -> Bool?
}
