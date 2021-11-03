//
//  GeneratePairIdUseCaseTests.swift
//  GeneratePairIdUseCaseTests
//
//  Created by 정지승 on 2021/11/03.
//

import Combine
import XCTest

class GeneratePairIdUseCaseTests: XCTestCase {
    private var generatePairIdUseCase: GeneratePairIdUseCase! = nil
    
    class MockUserRepository: UserRepositoryProtocol {
        static let testSuccessId1 = "2f48f241-9d64-4d16-bf56-70b9d4e0e791"
        static let testSuccessId2 = "2f48f241-9d64-4d16-bf56-70b9d4e0e721"
        static let testFailureId = "2f48f241-9d64-4d16-bf56-70b9d4e0e711"
        
        func fetchMyId() -> AnyPublisher<String, Error> {
            Future<String, Error>.init { promise in
                promise(.success(""))
            }.eraseToAnyPublisher()
        }
        
        func fetchPairId() -> AnyPublisher<String, Error> {
            Future<String, Error>.init { promise in
                promise(.success(""))
            }.eraseToAnyPublisher()
        }
        
        func saveMyId(_ id: String) -> AnyPublisher<Bool, Error> {
            Future<Bool, Error>.init { promise in
                promise(.success(true))
            }.eraseToAnyPublisher()
        }
        
        func savePairId(myId: String, friendId: String, pairId: String) -> AnyPublisher<Bool, Error> {
            Future<Bool, Error>.init { promise in
                promise(.success(myId == Self.testSuccessId1 && friendId == Self.testSuccessId2))
            }.eraseToAnyPublisher()
        }
        
        func checkUserIdIsExist(_ id: String) -> AnyPublisher<Bool, Error> {
            Future<Bool, Error>.init { promise in
                promise(.success(id == Self.testSuccessId1 || id == Self.testSuccessId2))
            }.eraseToAnyPublisher()
        }
    }
    
    override func setUpWithError() throws {
        self.generatePairIdUseCase = GeneratePairIdUseCase(userRepository: MockUserRepository())
    }

    override func tearDownWithError() throws {
        self.generatePairIdUseCase = nil
    }

    func testGeneratePairId_Success() {
        self.generatePairIdUseCase.generatePairId(
            myId: MockUserRepository.testSuccessId1,
            friendId: MockUserRepository.testSuccessId2
        )
        
        let testExpectation = expectation(description: "")
        
        _ = self.generatePairIdUseCase.pairedIdPublisher.sink { result in
            XCTAssertNil(result)
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testGeneratePairId_Failure_SameUserId() {
        self.generatePairIdUseCase.generatePairId(
            myId: MockUserRepository.testSuccessId1,
            friendId: MockUserRepository.testSuccessId1
        )
        
        let testExpectation = expectation(description: "")
        
        _ = self.generatePairIdUseCase.errorPublisher.sink { error in
            XCTAssertNotNil(error)
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testGeneratePairId_Failure_NotExistUserId() {
        self.generatePairIdUseCase.generatePairId(
            myId: MockUserRepository.testSuccessId1,
            friendId: MockUserRepository.testFailureId
        )
        
        let testExpectation = expectation(description: "")
        
        _ = self.generatePairIdUseCase.errorPublisher.sink { error in
            XCTAssertNotNil(error)
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

}
