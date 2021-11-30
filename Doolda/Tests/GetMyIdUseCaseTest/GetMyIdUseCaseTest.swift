//
//  GetMyIdUseCaseTest.swift
//  GetMyIdUseCaseTest
//
//  Created by 김민주 on 2021/11/30.
//

import Combine
import XCTest

class GetMyIdUseCaseTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown(){
        self.cancellables = []
    }

    func testGetMyIdSuccess() {
        guard let targetDDID = DDID(from: UUID.init().uuidString) else {
            XCTFail()
            return
        }
        
        let getMyIdUseCase = GetMyIdUseCase(
            userRepository: DummyUserRepository(dummyMyId: targetDDID, isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testGetMyIdSuccess")
        
        var result: DDID?
        
        getMyIdUseCase.getMyId()
            .sink { ddid in
                result = ddid
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 5)
        XCTAssertEqual(result, targetDDID)
    }
    
    func testGetMyIdFailure() {
        guard let targetDDID = DDID(from: UUID.init().uuidString) else {
            XCTFail()
            return
        }
        
        let getMyIdUseCase = GetMyIdUseCase(
            userRepository: DummyUserRepository(dummyMyId: targetDDID, isSuccessMode: false)
        )
        
        let expectation = self.expectation(description: "testGetMyIdFailure")
        
        var result: DDID?
        
        getMyIdUseCase.getMyId()
            .sink { ddid in
                result = ddid
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 5)
        XCTAssertNil(result)
    }
}
