//
//  PushNotificationStateUseCaseTest.swift
//  PushNotificationStateUseCaseTest
//
//  Created by 김민주 on 2021/11/30.
//

import Combine
import XCTest

class PushNotificationStateUseCaseTest: XCTestCase {

    func testSetPushNotificationStateAsTrue() {
        let targetState = true
        let dummyPushNotificationStateRepository = DummyPushNotificationStateRepository()
        let pushNotificationStateUseCase = PushNotificationStateUseCase(
            pushNotificationStateRepository: dummyPushNotificationStateRepository
        )

        pushNotificationStateUseCase.setPushNotificationState(as: targetState)
        
        XCTAssertEqual(targetState, dummyPushNotificationStateRepository.dummyNotificationState)
    }
    
    func testSetPushNotificationStateAsFalse() {
        let targetState = false
        let dummyPushNotificationStateRepository = DummyPushNotificationStateRepository()
        let pushNotificationStateUseCase = PushNotificationStateUseCase(
            pushNotificationStateRepository: dummyPushNotificationStateRepository
        )

        pushNotificationStateUseCase.setPushNotificationState(as: targetState)
        
        XCTAssertEqual(targetState, dummyPushNotificationStateRepository.dummyNotificationState)
    }
    
    func testFetchPushNotificationStateSuccess() {
        let targetState = true
        let dummyPushNotificationStateRepository = DummyPushNotificationStateRepository(dummyNotificationState: targetState)
        let pushNotificationStateUseCase = PushNotificationStateUseCase(
            pushNotificationStateRepository: dummyPushNotificationStateRepository
        )

        guard let result = pushNotificationStateUseCase.getPushNotificationState() else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(targetState, result)
    }
}
