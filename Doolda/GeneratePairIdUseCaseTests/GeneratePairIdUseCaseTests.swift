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
    
    class DummyUserRepository: UserRepositoryProtocol {
        enum Errors: Error {
            case notImplemented
            case failedToPair
        }
        
        static let testSuccessId1 = "2f48f241-9d64-4d16-bf56-70b9d4e0e791"
        static let testSuccessId2 = "2f48f241-9d64-4d16-bf56-70b9d4e0e721"
        static let testFailureId = "2f48f241-9d64-4d16-bf56-70b9d4e0e711"

        func fetchMyId() -> AnyPublisher<String, Error> {
            return Fail(error: Errors.notImplemented).eraseToAnyPublisher()
        }
        
        func fetchPairId(for id: String) -> AnyPublisher<String, Error> {
            return Fail(error: Errors.notImplemented).eraseToAnyPublisher()
        }
        
        func saveMyId(_ id: String) -> AnyPublisher<String, Error> {
            return Fail(error: Errors.notImplemented).eraseToAnyPublisher()
        }
        
        func savePairId(myId: String, friendId: String, pairId: String) -> AnyPublisher<String, Error> {
            let isValid = myId == DummyUserRepository.testSuccessId1 && friendId == DummyUserRepository.testSuccessId2
            return isValid ? Just(myId).setFailureType(to: Error.self).eraseToAnyPublisher() : Fail(error: Errors.failedToPair).eraseToAnyPublisher()
        }
        
        func checkUserIdIsExist(_ id: String) -> AnyPublisher<Bool, Error> {
            return Just(id == DummyUserRepository.testSuccessId1 || id == DummyUserRepository.testSuccessId2).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }
    
    override func setUpWithError() throws {
        self.generatePairIdUseCase = GeneratePairIdUseCase(userRepository: DummyUserRepository())
    }

    override func tearDownWithError() throws {
        self.generatePairIdUseCase = nil
    }

    func testGeneratePairId_Success() {
        self.generatePairIdUseCase.generatePairId(
            myId: DummyUserRepository.testSuccessId1,
            friendId: DummyUserRepository.testSuccessId2
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
            myId: DummyUserRepository.testSuccessId1,
            friendId: DummyUserRepository.testSuccessId1
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
            myId: DummyUserRepository.testSuccessId1,
            friendId: DummyUserRepository.testFailureId
        )
        
        let testExpectation = expectation(description: "")
        
        _ = self.generatePairIdUseCase.errorPublisher.sink { error in
            XCTAssertNotNil(error)
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

}
