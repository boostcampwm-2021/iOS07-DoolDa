//
//  GetUserUseCaseTest.swift
//  GetUserUseCaseTest
//
//  Created by Seunghun Yang on 2021/11/30.
//

import Combine
import XCTest

class GetUserUseCaseTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        self.cancellables = []
    }
    
    func testGetUserSuccess() {
        let userRepository = DummyUserRepository(isSuccessMode: true)
        let getUserUseCase = GetUserUseCase(userRepository: userRepository)
        
        let expectation = self.expectation(description: "testGetUserSuccess")
        
        var error: Error?
        var result: User?
        
        getUserUseCase.getUser(for: DummyUserRepository.firstUserId)
            .compactMap { $0 }
            .sink { completion in
                guard case .failure(let encounteredError) = completion else { return }
                error = encounteredError
                expectation.fulfill()
            } receiveValue: { user in
                result = user
                expectation.fulfill()
            }
            .store(in: &self.cancellables)

        waitForExpectations(timeout: 1)
        
        XCTAssertNil(error)
        XCTAssertEqual(result, User(id: DummyUserRepository.firstUserId, pairId: nil, friendId: nil))
    }
    
    func testGetUserFailure() {
        let userRepository = DummyUserRepository(isSuccessMode: false)
        let getUserUseCase = GetUserUseCase(userRepository: userRepository)
        
        let expectation = self.expectation(description: "testGetUserFailure")
        
        var error: Error?
        var result: User?
        
        getUserUseCase.getUser(for: DummyUserRepository.thirdUserId)
            .compactMap { $0 }
            .sink { completion in
                guard case .failure(let encounteredError) = completion else { return }
                error = encounteredError
                expectation.fulfill()
            } receiveValue: { user in
                result = user
                expectation.fulfill()
            }
            .store(in: &self.cancellables)

        waitForExpectations(timeout: 1)
        
        XCTAssertNotNil(error)
        XCTAssertNotEqual(result, User(id: DummyUserRepository.thirdUserId, pairId: nil, friendId: nil))
    }
}
