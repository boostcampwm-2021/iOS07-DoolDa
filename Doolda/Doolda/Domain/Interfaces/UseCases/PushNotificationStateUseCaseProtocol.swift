//
//  PushNotificationStateUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Foundation

protocol PushNotificationStateUseCaseProtocol {
    func getPushNotificationState() -> Bool?
    func setPushNotificationState(as state: Bool)
}
