//
//  PushNotificationStateUseCase.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/16.
//

import Foundation

protocol PushNotificationStateUseCaseProtocol {
    func getPushNotificationState() -> Bool?
    func setPushNotificationState(as state: Bool)
}

final class PushNotificationStateUseCase: PushNotificationStateUseCaseProtocol {
    private let pushNotificationStateRepository: PushNotificationStateRepositoryProtocol
        
    init(pushNotificationStateRepository: PushNotificationStateRepositoryProtocol) {
        self.pushNotificationStateRepository = pushNotificationStateRepository
    }
    
    func getPushNotificationState() -> Bool? {
        return self.pushNotificationStateRepository.fetchState()
    }
    
    func setPushNotificationState(as state: Bool) {
        self.pushNotificationStateRepository.saveState(as: state)
    }
}
