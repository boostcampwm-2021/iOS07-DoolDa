//
//  FirebaseMessageUseCaseTest.swift
//  FirebaseMessageUseCaseTest
//
//  Created by Seunghun Yang on 2021/11/30.
//

import Combine
import XCTest

class FirebaseMessageUseCaseTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []
    
    override func tearDown() {
        self.cancellables = []
    }
    
    func testSendMessageSuccess() {
        let fcmTokenRepository = DummyFCMTokenRepository(isSuccessMode: true)
        let firebaseMessageRepository = DummyFirebaseMessageRepository(isSuccessMode: true)
        let fireBaseMessageUseCase = FirebaseMessageUseCase(
            fcmTokenRepository: fcmTokenRepository,
            firebaseMessageRepository: firebaseMessageRepository
        )
        
        let expectation = self.expectation(description: #function)
        var error: Error?
        
        fireBaseMessageUseCase.sendMessage(to: DDID(), message: PushMessageEntity.userPairedWithFriend)
        
        fireBaseMessageUseCase.errorPublisher
            .sink {
                error = $0
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 3)
        XCTAssertNil(error)
    }
    
    func testSendMessageFailureDueToTokenRepository() {
        let fcmTokenRepository = DummyFCMTokenRepository(isSuccessMode: false)
        let firebaseMessageRepository = DummyFirebaseMessageRepository(isSuccessMode: true)
        let fireBaseMessageUseCase = FirebaseMessageUseCase(
            fcmTokenRepository: fcmTokenRepository,
            firebaseMessageRepository: firebaseMessageRepository
        )
        
        let expectation = self.expectation(description: #function)
        var error: Error?
        
        fireBaseMessageUseCase.sendMessage(to: DDID(), message: PushMessageEntity.userPairedWithFriend)
        
        fireBaseMessageUseCase.errorPublisher
            .sink {
                error = $0
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 3)
        XCTAssertNotNil(error)
    }
    
    func testSendMessageFailureDueToMessageRepository() {
        let fcmTokenRepository = DummyFCMTokenRepository(isSuccessMode: true)
        let firebaseMessageRepository = DummyFirebaseMessageRepository(isSuccessMode: false)
        let fireBaseMessageUseCase = FirebaseMessageUseCase(
            fcmTokenRepository: fcmTokenRepository,
            firebaseMessageRepository: firebaseMessageRepository
        )
        
        let expectation = self.expectation(description: #function)
        var error: Error?
        
        fireBaseMessageUseCase.sendMessage(to: DDID(), message: PushMessageEntity.userPairedWithFriend)
        
        fireBaseMessageUseCase.errorPublisher
            .sink {
                error = $0
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 3)
        XCTAssertNotNil(error)
    }
    
    func testSendMessageFailureDueToTokenAndMessageRepository() {
        let fcmTokenRepository = DummyFCMTokenRepository(isSuccessMode: false)
        let firebaseMessageRepository = DummyFirebaseMessageRepository(isSuccessMode: false)
        let fireBaseMessageUseCase = FirebaseMessageUseCase(
            fcmTokenRepository: fcmTokenRepository,
            firebaseMessageRepository: firebaseMessageRepository
        )
        
        let expectation = self.expectation(description: #function)
        var error: Error?
        
        fireBaseMessageUseCase.sendMessage(to: DDID(), message: PushMessageEntity.userPairedWithFriend)
        
        fireBaseMessageUseCase.errorPublisher
            .sink {
                error = $0
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 3)
        XCTAssertNotNil(error)
    }
}
