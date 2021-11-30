//
//  PairUserUseCaseTest.swift
//  PairUserUseCaseTest
//
//  Created by 정지승 on 2021/11/30.
//

import Combine
import XCTest

class PairUserUseCaseTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDownWithError() throws {
        self.cancellables = []
    }

    func testPairWithMyselfSuccess() {
        let user = User(id: DDID(), pairId: nil, friendId: nil)
        
        let pairUserUseCase = PairUserUseCase(
            userRepository: DummyUserRepository(dummyMyId: user.id, isSuccessMode: true),
            pairRepository: DummyPairRepository(isSuccessMode: true)
        )
        
        let expectation = expectation(description: #function)
        
        pairUserUseCase.pair(user: user)
        pairUserUseCase.pairedUserPublisher
            .sink { user in
                if let user = user,
                   let pairId = user.pairId,
                   let friendId = user.friendId {
                    XCTAssertEqual(user.id, friendId)
                    XCTAssertEqual(user.id, pairId)
                } else {
                    XCTFail()
                }
                
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        var errorResult: Error?
        pairUserUseCase.errorPublisher
            .sink { error in
                errorResult = error
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 10)
        
        XCTAssertNil(errorResult)
    }
    
    func testPairWithMyselfFailure() {
        let user = User(id: DDID(), pairId: nil, friendId: nil)
        
        let pairUserUseCase = PairUserUseCase(
            userRepository: DummyUserRepository(dummyMyId: user.id, isSuccessMode: true),
            pairRepository: DummyPairRepository(isSuccessMode: false)
        )
        
        let expectation = expectation(description: #function)
        
        pairUserUseCase.pair(user: user)
        pairUserUseCase.pairedUserPublisher
            .sink { user in
                XCTAssertNil(user?.pairId)
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        var errorResult: Error?
        pairUserUseCase.errorPublisher
            .sink { error in
                errorResult = error
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 10)
        
        XCTAssertNotNil(errorResult)
    }
    
    func testPairWithFriendSuccess() {
        let user = User(id: DDID(), pairId: nil, friendId: nil)
        
        let pairUserUseCase = PairUserUseCase(
            userRepository: DummyUserRepository(dummyMyId: user.id, isSuccessMode: true),
            pairRepository: DummyPairRepository(isSuccessMode: true)
        )
        
        let expectation = expectation(description: #function)
        
        let friendId = DDID()
        pairUserUseCase.pair(user: user, friendId: friendId)
        pairUserUseCase.pairedUserPublisher
            .sink { user in
                if let user = user,
                   let friendIdResult = user.friendId {
                    XCTAssertNotNil(user.pairId)
                    XCTAssertEqual(friendId, friendIdResult)
                } else {
                    XCTFail()
                }
                
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        var errorResult: Error?
        pairUserUseCase.errorPublisher
            .sink { error in
                errorResult = error
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 10)
        
        XCTAssertNil(errorResult)
    }
    
    func testPairWithFriendFailure() {
        let user = User(id: DDID(), pairId: nil, friendId: nil)
        
        let pairUserUseCase = PairUserUseCase(
            userRepository: DummyUserRepository(dummyMyId: user.id, isSuccessMode: true),
            pairRepository: DummyPairRepository(isSuccessMode: false)
        )
        
        let expectation = expectation(description: #function)
        
        let friendId = DDID()
        pairUserUseCase.pair(user: user, friendId: friendId)
        pairUserUseCase.pairedUserPublisher
            .sink { user in
                XCTAssertNil(user?.pairId)
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        var errorResult: Error?
        pairUserUseCase.errorPublisher
            .sink { error in
                errorResult = error
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 10)
        
        XCTAssertNotNil(errorResult)
    }
}
