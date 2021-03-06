//
//  PushNotificationStateUseCase.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/16.
//

import Foundation

final class PushNotificationStateUseCase: PushNotificationStateUseCaseProtocol {
    private let pushNotificationStateRepository: PushNotificationStateRepositoryProtocol
        
    init(pushNotificationStateRepository: PushNotificationStateRepositoryProtocol) {
        self.pushNotificationStateRepository = pushNotificationStateRepository
    }
    
    func getPushNotificationState() -> Bool? {
        return self.pushNotificationStateRepository.fetch()
    }
    
    func setPushNotificationState(as state: Bool) {
        self.pushNotificationStateRepository.save(state)
    }
}
