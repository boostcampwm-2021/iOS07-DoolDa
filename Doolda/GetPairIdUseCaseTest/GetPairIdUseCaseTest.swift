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

    class DummyUserRepository: UserRepositoryProtocol {
        static let notExistingUser = "00000000-0000-0000-0000-000000000000"
        static let userWithoutPair = "00000000-0000-0000-0000-000000000001"
        static let userWithPair = "00000000-0000-0000-0000-000000000002"
        static let pairId = "00000000-0000-0000-0000-000000000003"
        
        enum Errors: LocalizedError {
            case userDoesNotExists
            case unknownError
        }
        
        func fetchMyId() -> AnyPublisher<String, Error> {
            return Just("NOT IMPLEMENTED").setFailureType(to: Error.self).eraseToAnyPublisher()
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

        func saveMyId(_ id : String) {
            return
        }
        
        func savePairId(_ id: String) {
            return
        }
    }
    
    override func setUpWithError() throws {
        self.getPairIdUseCase = GetPairIdUseCase(userRepository: DummyUserRepository())
    }

    override func tearDownWithError() throws {
        self.getPairIdUseCase = nil
    }

    func testGetPairIdSuccessForUserWithPair() {
        self.getPairIdUseCase?.getPairId(for: DummyUserRepository.userWithPair)
            .sink(receiveCompletion: { completion in
                guard case .failure(_) = completion else { return }
                XCTFail()
            }, receiveValue: { pairId in
                XCTAssertEqual(DummyUserRepository.pairId, pairId)
            })
            .cancel()
    }
    
    func testGetPairIdSuccessForUserWithoutPair() {
        self.getPairIdUseCase?.getPairId(for: DummyUserRepository.userWithoutPair)
            .sink(receiveCompletion: { completion in
                guard case .failure(_) = completion else { return }
                XCTFail()
            }, receiveValue: { pairId in
                XCTAssertEqual("", pairId)
            })
            .cancel()
    }

    func testGetPairIdSuccessForNotExistingUser() {
        self.getPairIdUseCase?.getPairId(for: DummyUserRepository.notExistingUser)
            .sink(receiveCompletion: { completion in
                guard case .failure(let error) = completion else { return XCTFail() }
                guard let error = error as? DummyUserRepository.Errors else { return XCTFail() }
                XCTAssertEqual(error, DummyUserRepository.Errors.userDoesNotExists)
            }, receiveValue: { _ in
                XCTFail()
            })
            .cancel()
    }
}
