//
//  GetMyIdUseCaseTests.swift
//  DooldaTests
//
//  Created by 김민주 on 2021/11/02.
//

import Combine
import XCTest

class GetMyIdUseCaseTests: XCTestCase {
    private var dummyRepository: UserRepositoryProtocol?
    private var getMyIdUseCase: GetMyIdUseCase?
    private var cancellables: Set<AnyCancellable> = []

    override func tearDownWithError() throws {
        self.getMyIdUseCase = nil
        self.dummyRepository = nil
        self.cancellables = []
    }

    func testGetMyIdSuceess() throws {
        class DummyRepository: UserRepositoryProtocol {
            enum Errors: Error {
                case notImplemented
            }

            func fetchMyId() -> AnyPublisher<String, Error> {
                return Just("00000000-0000-0000-0000-000000000001").setFailureType(to: Error.self).eraseToAnyPublisher()
            }

            func fetchPairId(for id: String) -> AnyPublisher<String, Error> {
                return Fail(error: Errors.notImplemented).eraseToAnyPublisher()
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
        
        let expectation = self.expectation(description: "testGetMyIdSuceess")
        var error: Error?
        var result: String?
        
        self.dummyRepository = DummyRepository()
        if let repository = self.dummyRepository {
            self.getMyIdUseCase = GetMyIdUseCase(userRepository: repository)
        }

        guard let usecase = self.getMyIdUseCase else { return XCTFail() }

        usecase.getMyId()
            .sink { completion in
                guard case .failure(let encounteredError) = completion else { return }
                error = encounteredError
                expectation.fulfill()
            } receiveValue: { id in
                result = id
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5)
        
        XCTAssertNil(error)
        XCTAssertEqual("00000000-0000-0000-0000-000000000001", result, "전달되는 id 값이 예상 id값과 다릅니다.")
    }

    func testGetMyIdError() throws {
        enum DummyError: Error {
            case dummyError
        }

        class DummyRepository: UserRepositoryProtocol {
            enum Errors: Error {
                case notImplemented
            }

            func fetchMyId() -> AnyPublisher<String, Error> {
                return Fail(error: DummyError.dummyError).eraseToAnyPublisher()
            }

            func fetchPairId(for id: String) -> AnyPublisher<String, Error> {
                return Fail(error: Errors.notImplemented).eraseToAnyPublisher()
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
        
        let expectation = self.expectation(description: "testGetMyIdError")
        var error: DummyError?
        var result: String?

        self.dummyRepository = DummyRepository()
        if let repository = self.dummyRepository {
            self.getMyIdUseCase = GetMyIdUseCase(userRepository: repository)
        }

        guard let usecase = self.getMyIdUseCase else { return XCTFail() }

        usecase.getMyId()
            .sink { completion in
                guard case .failure(let encounteredError) = completion else { return }
                error = encounteredError as? DummyError
                expectation.fulfill()
            } receiveValue: { id in
                result = id
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5)
        
        XCTAssertEqual(error, DummyError.dummyError)
        XCTAssertNil(result)
    }
}
