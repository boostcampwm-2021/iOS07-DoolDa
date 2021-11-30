//
//  DummyPushNotificationStateRepository.swift
//  PushNotificationStateUseCaseTest
//
//  Created by 김민주 on 2021/11/30.
//

import Foundation

class DummyPushNotificationStateRepository: PushNotificationStateRepositoryProtocol {
    var dummyNotificationState: Bool?
    
    init(dummyNotificationState: Bool? = nil) {
        self.dummyNotificationState = dummyNotificationState
    }
    
    func save( _ state: Bool) {
        self.dummyNotificationState = state
    }
    
    func fetch() -> Bool? {
        return dummyNotificationState
    }
}
