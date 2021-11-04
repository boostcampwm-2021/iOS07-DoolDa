//
//  GetPairIdUseCaseTest.swift
//  GetPairIdUseCaseTest
//
//  Created by Seunghun Yang on 2021/11/03.
//

import Combine
import XCTest

class GetPairIdUseCaseTest: XCTestCase {
    private var getPairIdUseCase: GetPairIdUseCase?
    private var cancellables: Set<AnyCancellable> = []

    class DummyUserRepository: UserRepositoryProtocol {
        static let notExistingUser = "00000000-0000-0000-0000-000000000000"
        static let userWithoutPair = "00000000-0000-0000-0000-000000000001"
        static let userWithPair = "00000000-0000-0000-0000-000000000002"
        static let pairId = "00000000-0000-0000-0000-000000000003"
        
        enum Errors: LocalizedError {
            case userDoesNotExists
            case unknownError
            case notImplemented
        }
        
        func fetchMyId() -> AnyPublisher<String, Error> {
            return Fail(error: Errors.notImplemented).eraseToAnyPublisher()
        }
    
        func fetchPairId(for id: String) -> AnyPublisher<String, Error> {
            switch id {
            case DummyUserRepository.notExistingUser:
                return Fail(error: Errors.userDoesNotExists).eraseToAnyPublisher()
            case DummyUserRepository.userWithPair:
                return Just(DummyUserRepository.pairId).setFailureType(to: Error.self).eraseToAnyPublisher()
            case DummyUserRepository.userWithoutPair:
                return Just("").setFailureType(to: Error.self).eraseToAnyPublisher()
            default:
                return Fail(error: Errors.unknownError).eraseToAnyPublisher()
            }
        }
        
        func saveMyId(_ id: String) -> AnyPublisher<String, Error> {
            return Fail(error: Errors.notImplemented).eraseToAnyPublisher()
        }
        
        func savePairId(myId: String, friendId: String, pairId: String) -> AnyPublisher<String, Error> {
            return Fail(error: Errors.notImplemented).eraseToAnyPublisher()
        }
        
        func checkUserIdIsExist(_ id: String) -> AnyPublisher<Bool, Error> {
            return Fail(error: Errors.notImplemented).eraseToAnyPublisher()
        }
    }
    
    override func setUpWithError() throws {
        self.getPairIdUseCase = GetPairIdUseCase(userRepository: DummyUserRepository())
    }

    override func tearDownWithError() throws {
        self.getPairIdUseCase = nil
        self.cancellables = []
    }

    func testGetPairIdSuccessForUserWithPair() {
        let expectation = self.expectation(description: "testGetPairIdSuccessForUserWithPair")
        var error: Error?
        var result: String?
        
        self.getPairIdUseCase?.getPairId(for: DummyUserRepository.userWithPair)
            .sink(receiveCompletion: { completion in
                guard case .failure(let encounteredError) = completion else { return }
                error = encounteredError
                expectation.fulfill()
            }, receiveValue: { pairId in
                result = pairId
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5)
        
        XCTAssertNil(error)
        XCTAssertEqual(result, DummyUserRepository.pairId)
    }
    
    func testGetPairIdSuccessForUserWithoutPair() {
        let expectation = self.expectation(description: "testGetPairIdSuccessForUserWithoutPair")
        var error: Error?
        var result: String?
        
        self.getPairIdUseCase?.getPairId(for: DummyUserRepository.userWithoutPair)
            .sink(receiveCompletion: { completion in
                guard case .failure(let encounteredError) = completion else { return }
                error = encounteredError
                expectation.fulfill()
            }, receiveValue: { pairId in
                result = pairId
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5)
        
        XCTAssertNil(error)
        XCTAssertEqual(result, "")
    }

    func testGetPairIdSuccessForNotExistingUser() {
        let expectation = self.expectation(description: "testGetPairIdSuccessForNotExistingUser")
        var error: DummyUserRepository.Errors?
        var result: String?
        
        self.getPairIdUseCase?.getPairId(for: DummyUserRepository.notExistingUser)
            .sink(receiveCompletion: { completion in
                guard case .failure(let encounteredError) = completion else { return XCTFail() }
                error = encounteredError as? DummyUserRepository.Errors
                expectation.fulfill()
            }, receiveValue: { pairId in
                result = pairId
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5)
        
        XCTAssertEqual(error, DummyUserRepository.Errors.userDoesNotExists)
        XCTAssertNil(result)
    }
}
