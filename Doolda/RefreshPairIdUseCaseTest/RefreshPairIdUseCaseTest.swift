//
//  RefreshPairIdUseCaseTest.swift
//  RefreshPairIdUseCaseTest
//
//  Created by 정지승 on 2021/11/04.
//

import Combine
import XCTest

final class RefreshPairIdUseCaseTest: XCTestCase {
    final class MockUserRepository: UserRepositoryProtocol {
        enum TestCase {
            case success
            case failureNotExist
            case failurePairIdIsEmpty
        }
        
        enum TestError: Error {
            case notExistId
        }
        
        private let testCase: TestCase
        
        init(testCase: TestCase) {
            self.testCase = testCase
        }
        
        func fetchMyId() -> AnyPublisher<String, Error> {
            Just<String>("").setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        func fetchPairId() -> AnyPublisher<String, Error> {
            switch testCase {
            case .success:
                return Just(UUID().uuidString).setFailureType(to: Error.self).eraseToAnyPublisher()
            case .failureNotExist:
                return Fail(error: TestError.notExistId).eraseToAnyPublisher()
            case .failurePairIdIsEmpty:
                return Just("").setFailureType(to: Error.self).eraseToAnyPublisher()
            }
        }
        
        func saveMyId(_ id: String) { }
        
        func savePairId(_ id: String) { }
    }
    
    func testRefreshPairId_success() {
        let refreshPairIdUseCase = RefreshPairIdUseCase(userRepository: MockUserRepository(testCase: .success))
        refreshPairIdUseCase.refreshPairId()
        
        refreshPairIdUseCase.pairedIdPublisher
            .sink { pairId in
                XCTAssertNotNil(pairId)
            }
            .cancel()
        
        refreshPairIdUseCase.errorPublisher
            .sink { error in
                XCTAssertNil(error)
            }
            .cancel()
    }
    
    func testRefreshPairId_failure_notExist() {
        let refreshPairIdUseCase = RefreshPairIdUseCase(userRepository: MockUserRepository(testCase: .failureNotExist))
        refreshPairIdUseCase.refreshPairId()
        
        refreshPairIdUseCase.pairedIdPublisher
            .sink { pairId in
                XCTAssertNil(pairId)
            }
            .cancel()
        
        refreshPairIdUseCase.errorPublisher
            .sink { error in
                XCTAssertNotNil(error)
            }
            .cancel()
    }
    
    func testRefreshPairId_failure_isEmpty() {
        let refreshPairIdUseCase = RefreshPairIdUseCase(userRepository: MockUserRepository(testCase: .failurePairIdIsEmpty))
        refreshPairIdUseCase.refreshPairId()
        
        refreshPairIdUseCase.pairedIdPublisher
            .sink { pairId in
                XCTAssertNil(pairId)
            }
            .cancel()
        
        refreshPairIdUseCase.errorPublisher
            .sink { error in
                XCTAssertNotNil(error)
            }
            .cancel()
    }
}
