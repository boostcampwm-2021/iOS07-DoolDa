//
//  RefreshPairIdUseCaseTest.swift
//  RefreshPairIdUseCaseTest
//
//  Created by 정지승 on 2021/11/04.
//

import Combine
import XCTest

final class RefreshPairIdUseCaseTest: XCTestCase {
    final class DummyUserRepository: UserRepositoryProtocol {
        enum TestCase {
            case success
            case failureNotExist
            case failurePairIdIsEmpty
        }
        
        enum TestError: Error {
            case notImplemented
            case notExistId
        }
        
        private let testCase: TestCase
        
        init(testCase: TestCase) {
            self.testCase = testCase
        }
        
        func fetchMyId() -> AnyPublisher<String, Error> {
            Just("").setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        func fetchPairId(for id: String) -> AnyPublisher<String, Error> {
            switch testCase {
            case .success:
                return Just(UUID().uuidString).setFailureType(to: Error.self).eraseToAnyPublisher()
            case .failureNotExist:
                return Fail(error: TestError.notExistId).eraseToAnyPublisher()
            case .failurePairIdIsEmpty:
                return Just("").setFailureType(to: Error.self).eraseToAnyPublisher()
            }
        }
        
        func saveMyId(_ id: String) -> AnyPublisher<String, Error> {
            Fail(error: TestError.notImplemented).eraseToAnyPublisher()
        }
        
        func savePairId(myId: String, friendId: String, pairId: String) -> AnyPublisher<String, Error> {
            Fail(error: TestError.notImplemented).eraseToAnyPublisher()
        }
        
        func checkUserIdIsExist(_ id: String) -> AnyPublisher<Bool, Error> {
            Fail(error: TestError.notImplemented).eraseToAnyPublisher()
        }
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func tearDownWithError() throws {
        self.cancellables.forEach({ $0.cancel() })
    }
    
    func testRefreshPairId_success() {
        let refreshPairIdUseCase = RefreshPairIdUseCase(userRepository: DummyUserRepository(testCase: .success))
        let expectation = expectation(description: "testRefreshPairId_success")
        
        refreshPairIdUseCase.pairIdPublisher
            .dropFirst()
            .sink { pairId in
                XCTAssertNotNil(pairId)
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        refreshPairIdUseCase.errorPublisher
            .dropFirst()
            .sink { error in
                XCTAssertNil(error)
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        refreshPairIdUseCase.refreshPairId(for: UUID().uuidString)
        waitForExpectations(timeout: 5)
    }
    
    func testRefreshPairId_failure_notExist() {
        let refreshPairIdUseCase = RefreshPairIdUseCase(userRepository: DummyUserRepository(testCase: .failureNotExist))
        let expectation = expectation(description: "testRefreshPairId_failure_notExist")
        
        refreshPairIdUseCase.pairIdPublisher
            .dropFirst()
            .sink { pairId in
                XCTAssertNil(pairId)
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        refreshPairIdUseCase.errorPublisher
            .dropFirst()
            .sink { error in
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        refreshPairIdUseCase.refreshPairId(for: UUID().uuidString)
        waitForExpectations(timeout: 5)
    }
    
    func testRefreshPairId_failure_isEmpty() {
        let refreshPairIdUseCase = RefreshPairIdUseCase(userRepository: DummyUserRepository(testCase: .failurePairIdIsEmpty))
        let expectation = expectation(description: "testRefreshPairId_failure_isEmpty")
        
        refreshPairIdUseCase.pairIdPublisher
            .dropFirst()
            .sink { pairId in
                XCTAssertEqual("", pairId)
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        refreshPairIdUseCase.errorPublisher
            .dropFirst()
            .sink { error in
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        refreshPairIdUseCase.refreshPairId(for: UUID().uuidString)
        waitForExpectations(timeout: 5)
    }
}
