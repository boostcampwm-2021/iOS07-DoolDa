//
//  FCMTokenUseCaseTest.swift
//  FCMTokenUseCaseTest
//
//  Created by Seunghun Yang on 2021/11/30.
//

import Combine
import XCTest

class FCMTokenUseCaseTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        self.cancellables = []
    }

    func testSetTokenSuccess() {
        let fcmTokenRepository = DummyFCMTokenRepository(isSuccessMode: true)
        let fcmTokenUseCase = FCMTokenUseCase(fcmTokenRepository: fcmTokenRepository)
        
        let expectation = self.expectation(description: "testSetTokenSuccess")
        var error: Error?
        var result: String?
        
        let dummyToken = "DUMMYTOKEN"
        fcmTokenUseCase.setToken(for: DDID(), with: dummyToken)
            .sink { completion in
                guard case .failure(let encounteredError) = completion else { return }
                error = encounteredError
                expectation.fulfill()
            } receiveValue: { token in
                result = token
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 3)
        
        XCTAssertNil(error)
        XCTAssertEqual(dummyToken, result)
    }
    
    func testSetTokenFailure() {
        let fcmTokenRepository = DummyFCMTokenRepository(isSuccessMode: false)
        let fcmTokenUseCase = FCMTokenUseCase(fcmTokenRepository: fcmTokenRepository)
        
        let expectation = self.expectation(description: "testSetTokenFailure")
        var error: Error?
        var result: String?
        
        let dummyToken = "DUMMYTOKEN"
        fcmTokenUseCase.setToken(for: DDID(), with: dummyToken)
            .sink { completion in
                guard case .failure(let encounteredError) = completion else { return }
                error = encounteredError
                expectation.fulfill()
            } receiveValue: { token in
                result = token
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 3)
        
        XCTAssertNotNil(error)
        XCTAssertNotEqual(dummyToken, result)
    }
}
