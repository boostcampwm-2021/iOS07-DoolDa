//
//  SplashViewModelTest.swift
//  SplashViewModelTest
//
//  Created by Dozzing on 2021/11/04.
//

import Combine
import XCTest

class SplashViewModelTest: XCTestCase {

    private var splashViewModel: SplashViewModel?
    private var dummyMyId: String?
    private var dummyPairId: String?

    enum DummyError: Error {
        case dummyError
    }

    class DummyCoordinator: SplashViewCoordinatorDelegate {
        enum Result {
            case notPaired
            case alreadyPaired
        }

        var result: Result?
        var myId: String?
        var pairId: String?

        func userNotPaired(myId: String) {
            self.result = .notPaired
            self.myId = myId
        }

        func userAlreadyPaired(myId: String, pairId: String) {
            self.result = .alreadyPaired
            self.myId = myId
            self.pairId = pairId
        }
    }

    class DummyGetMyIdUseCase: GetMyIdUseCaseProtocol {
        private var mockMyId: String?

        init(mockMyId: String?) {
            self.mockMyId = mockMyId
        }

        func getMyId() -> AnyPublisher<String, Error> {
            guard let myId = self.mockMyId else {
                return Result.Publisher(DummyError.dummyError).eraseToAnyPublisher()
            }
            return Result.Publisher(myId).eraseToAnyPublisher()
        }
    }

    class DummyGetPairIdUseCase: GetPairIdUseCaseProtocol {
        private var mockPairId: String?

        init(mockPariId: String?) {
            self.mockPairId = mockPariId
        }

        func getPairId(for id: String) -> AnyPublisher<String, Error> {
            guard let pairId = self.mockPairId else {
                return Result.Publisher(DummyError.dummyError).eraseToAnyPublisher()
            }
            return Result.Publisher(pairId).eraseToAnyPublisher()
        }
    }

    class DummyGenerateMyIdUseCase: GenerateMyIdUseCaseProtocol {
        var savedIdPublisher: Published<String?>.Publisher { self.$savedId }
        var errorPublisher: Published<Error?>.Publisher { self.$error }

        @Published private var savedId: String?
        @Published private var error: Error?

        private var mockMyId: String?

        init(mockMyId: String?) {
            self.mockMyId = mockMyId
        }

        func generate() {
            guard let myId = self.mockMyId else {
                self.error = DummyError.dummyError
                return
            }
            self.savedId = myId
        }
    }

    override func setUpWithError() throws {
        self.splashViewModel = nil
        self.dummyMyId = "00000000-0000-0000-0000-000000000001"
        self.dummyPairId = "00000000-0000-0000-0000-000000000002"
    }

    func testGetMyIdFail_GenerateMyIdFail() throws {
        let mockCoordinatorDelegate = DummyCoordinator()
        let mockGetMyIdUseCase = DummyGetMyIdUseCase(mockMyId: nil)
        let mockGetPairIdUseCase = DummyGetPairIdUseCase(mockPariId: nil)
        let mockGenerateMyIdUseCase = DummyGenerateMyIdUseCase(mockMyId: nil)
        self.splashViewModel = SplashViewModel(
            coordinatorDelegate: mockCoordinatorDelegate,
            getMyIdUseCase: mockGetMyIdUseCase,
            getPairIdUseCase: mockGetPairIdUseCase,
            generateMyIdUseCase: mockGenerateMyIdUseCase
        )

        self.splashViewModel?.prepareUserInfo()
        XCTAssertNotNil(self.splashViewModel?.error, "Incorrect error")
        XCTAssertNil(mockCoordinatorDelegate.result, "Incorrect coordinator result")
        XCTAssertNil(mockCoordinatorDelegate.myId, "Incorrect myId")
        XCTAssertNil(mockCoordinatorDelegate.pairId, "Incorrect pairId")
    }

    func testGetMyIdFail_GenerateMyIdSuccess() throws {
        let mockCoordinatorDelegate = DummyCoordinator()
        let mockGetMyIdUseCase = DummyGetMyIdUseCase(mockMyId: nil)
        let mockGetPairIdUseCase = DummyGetPairIdUseCase(mockPariId: nil)
        let mockGenerateMyIdUseCase = DummyGenerateMyIdUseCase(mockMyId: self.dummyMyId)
        self.splashViewModel = SplashViewModel(
            coordinatorDelegate: mockCoordinatorDelegate,
            getMyIdUseCase: mockGetMyIdUseCase,
            getPairIdUseCase: mockGetPairIdUseCase,
            generateMyIdUseCase: mockGenerateMyIdUseCase
        )

        self.splashViewModel?.prepareUserInfo()
        XCTAssertEqual(mockCoordinatorDelegate.result, .notPaired, "Incorrect coordinator result")
        XCTAssertEqual(mockCoordinatorDelegate.myId, self.dummyMyId, "Incorrect myId")
        XCTAssertNil(mockCoordinatorDelegate.pairId, "Incorrect pairId")
    }

    func testGetMyIdSuccess_GetPairIdFail() throws {
        let mockCoordinatorDelegate = DummyCoordinator()
        let mockGetMyIdUseCase = DummyGetMyIdUseCase(mockMyId: self.dummyMyId)
        let mockGetPairIdUseCase = DummyGetPairIdUseCase(mockPariId: nil)
        let mockGenerateMyIdUseCase = DummyGenerateMyIdUseCase(mockMyId: self.dummyMyId)
        self.splashViewModel = SplashViewModel(
            coordinatorDelegate: mockCoordinatorDelegate,
            getMyIdUseCase: mockGetMyIdUseCase,
            getPairIdUseCase: mockGetPairIdUseCase,
            generateMyIdUseCase: mockGenerateMyIdUseCase
        )

        self.splashViewModel?.prepareUserInfo()
        XCTAssertEqual(mockCoordinatorDelegate.result, .notPaired, "Incorrect coordinator result")
        XCTAssertEqual(mockCoordinatorDelegate.myId, self.dummyMyId, "Incorrect myId")
        XCTAssertNil(mockCoordinatorDelegate.pairId, "Incorrect pairId")
    }

    func testGetMyIdSuccess_GetPairIdSuccess() throws {
        let mockCoordinatorDelegate = DummyCoordinator()
        let mockGetMyIdUseCase = DummyGetMyIdUseCase(mockMyId: self.dummyMyId)
        let mockGetPairIdUseCase = DummyGetPairIdUseCase(mockPariId: self.dummyPairId)
        let mockGenerateMyIdUseCase = DummyGenerateMyIdUseCase(mockMyId: self.dummyMyId)
        self.splashViewModel = SplashViewModel(
            coordinatorDelegate: mockCoordinatorDelegate,
            getMyIdUseCase: mockGetMyIdUseCase,
            getPairIdUseCase: mockGetPairIdUseCase,
            generateMyIdUseCase: mockGenerateMyIdUseCase
        )

        self.splashViewModel?.prepareUserInfo()
        XCTAssertEqual(mockCoordinatorDelegate.result, .alreadyPaired, "Incorrect coordinator result")
        XCTAssertEqual(mockCoordinatorDelegate.myId, self.dummyMyId, "Incorrect myId")
        XCTAssertEqual(mockCoordinatorDelegate.pairId, self.dummyPairId, "Incorrect pairId")
    }

}
