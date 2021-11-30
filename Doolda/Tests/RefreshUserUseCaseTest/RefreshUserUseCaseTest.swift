//
//  RefreshUserUseCaseTest.swift
//  RefreshUserUseCaseTest
//
//  Created by 정지승 on 2021/11/30.
//

import Combine
import XCTest

class RefreshUserUseCaseTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDownWithError() throws {
        self.cancellables = []
    }
    
    func testRefreshUserSuccess() {
        let refreshUserUseCase = RefreshUserUseCase(
            userRepository: DummyUserRepository(
                dummyMyId: DummyUserRepository.fourthUserId,
                isSuccessMode: true
            )
        )
        
        let expectation = expectation(description: #function)
        
        let user = User(id: DummyUserRepository.fourthUserId, pairId: nil, friendId: nil)
        refreshUserUseCase.refresh(for: user)
        refreshUserUseCase.refreshedUserPublisher
            .sink { user in
                XCTAssertNotNil(user)
                XCTAssertNotNil(user?.friendId)
                XCTAssertNotNil(user?.pairId)
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        refreshUserUseCase.errorPublisher
            .compactMap { $0 }
            .sink { error in
                XCTFail()
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 10)
    }
    
    func testRefreshUserFailure() {
        let refreshUserUseCase = RefreshUserUseCase(
            userRepository: DummyUserRepository(
                dummyMyId: DummyUserRepository.fourthUserId,
                isSuccessMode: false
            )
        )
        
        let expectation = expectation(description: #function)
        
        let user = User(id: DummyUserRepository.fourthUserId, pairId: nil, friendId: nil)
        refreshUserUseCase.refresh(for: user)
        refreshUserUseCase.refreshedUserPublisher
            .sink { user in
                XCTAssertNil(user)
            }
            .store(in: &self.cancellables)
        
        refreshUserUseCase.errorPublisher
            .compactMap { $0 }
            .sink { error in
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 10)
    }
}
