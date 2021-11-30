//
//  PushNotificationStateRepository.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/16.
//

import Foundation

final class PushNotificationStateRepository: PushNotificationStateRepositoryProtocol {
    private let userDefaultsPersistenceService: UserDefaultsPersistenceServiceProtocol
    
    init(persistenceService: UserDefaultsPersistenceServiceProtocol) {
        self.userDefaultsPersistenceService = persistenceService
    }
    
    func save(_ state: Bool) {
        self.userDefaultsPersistenceService.set(key: UserDefaults.Keys.pushNotificationState, value: state)
    }
    
    func fetch() -> Bool? {
        guard let pushNotificationState: Bool = self.userDefaultsPersistenceService.get(
            key: UserDefaults.Keys.pushNotificationState
        ) else {
            return nil
        }
        return pushNotificationState
    }
}
