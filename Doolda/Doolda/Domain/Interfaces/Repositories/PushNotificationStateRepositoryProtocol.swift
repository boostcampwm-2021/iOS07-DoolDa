//
//  PushNotificationStateRepositoryProtocol.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/16.
//

import Foundation

protocol PushNotificationStateRepositoryProtocol {
    func save(_ state: Bool)
    func fetch() -> Bool?
}
