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
    private var mockMyId: String?
    private var mockPairId: String?

    enum DummyError: Error {
        case dummyError
    }

    class MockCoordinatorDelegate: SplashViewCoordinatorDelegate {
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

    class MockGetMyIdUseCase: GetMyIdUseCaseProtocol {
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

    class MockGetPairIdUseCase: GetPairIdUseCaseProtocol {
        private var mockPairId: String?

        init(mockPariId: String?) {
            self.mockPairId = mockPariId
        }

        func getPairId(with myId: String) -> AnyPublisher<String, Error> {
            guard let pairId = self.mockPairId else {
                return Result.Publisher(DummyError.dummyError).eraseToAnyPublisher()
            }
            return Result.Publisher(pairId).eraseToAnyPublisher()
        }
    }

    class MockGenerateMyIdUseCase: GenerateMyIdUseCaseProtocol {
        private var mockMyId: String?

        init(mockMyId: String?) {
            self.mockMyId = mockMyId
        }

        func generateMyId() -> AnyPublisher<String, Error> {
            guard let myId = self.mockMyId else {
                return Result.Publisher(DummyError.dummyError).eraseToAnyPublisher()
            }
            return Result.Publisher(myId).eraseToAnyPublisher()
        }
    }

    override func setUpWithError() throws {
        self.splashViewModel = nil
        self.mockMyId = "00000000-0000-0000-0000-000000000001"
        self.mockPairId = "00000000-0000-0000-0000-000000000002"
    }

    // 내 아이디 가져오기 실패 -> 내 아이디 만들기 실패
    // 내 아이디 가져오기 실패 -> 내 아이디 만들기 성공
    // 내 아이디 가져오기 성공 -> 짝 아이디 가져오기 실패
    // 내 아이디 가져오기 성공 -> 짝 아이디 가져오기 성공

    func testGetMyIdFail_GenerateMyIdSuccess() throws {
        let mockCoordinatorDelegate = MockCoordinatorDelegate()
        let mockGetMyIdUseCase = MockGetMyIdUseCase(mockMyId: nil)
        let mockGetPairIdUseCase = MockGetPairIdUseCase(mockPariId: nil)
        let mockGenerateMyIdUseCase = MockGenerateMyIdUseCase(mockMyId: self.mockMyId)
        self.splashViewModel = SplashViewModel(coordinatorDelegate: mockCoordinatorDelegate,
                                               getMyIdUseCase: mockGetMyIdUseCase,
                                               getPairIdUseCase: mockGetPairIdUseCase,
                                               generateMyIdUseCase: mockGenerateMyIdUseCase
                                               )

        self.splashViewModel?.viewDidLoad()
        XCTAssertEqual(mockCoordinatorDelegate.result, .notPaired, "Incorrect coordinator result")
        XCTAssertEqual(mockCoordinatorDelegate.myId, self.mockMyId, "Incorrect myId")
        XCTAssertNil(mockCoordinatorDelegate.pairId, "Incorrect pairId")
    }

    func testGetMyIdSuccess_GetPairIdFail() throws {
        let mockCoordinatorDelegate = MockCoordinatorDelegate()
        let mockGetMyIdUseCase = MockGetMyIdUseCase(mockMyId: self.mockMyId)
        let mockGetPairIdUseCase = MockGetPairIdUseCase(mockPariId: nil)
        let mockGenerateMyIdUseCase = MockGenerateMyIdUseCase(mockMyId: self.mockMyId)
        self.splashViewModel = SplashViewModel(coordinatorDelegate: mockCoordinatorDelegate,
                                               getMyIdUseCase: mockGetMyIdUseCase,
                                               getPairIdUseCase: mockGetPairIdUseCase,
                                               generateMyIdUseCase: mockGenerateMyIdUseCase
                                               )

        self.splashViewModel?.viewDidLoad()
        XCTAssertEqual(mockCoordinatorDelegate.result, .notPaired, "Incorrect coordinator result")
        XCTAssertEqual(mockCoordinatorDelegate.myId, self.mockMyId, "Incorrect myId")
        XCTAssertNil(mockCoordinatorDelegate.pairId, "Incorrect pairId")
    }

    func testGetMyIdSuccess_GetPairIdSuccess() throws {
        let mockCoordinatorDelegate = MockCoordinatorDelegate()
        let mockGetMyIdUseCase = MockGetMyIdUseCase(mockMyId: self.mockMyId)
        let mockGetPairIdUseCase = MockGetPairIdUseCase(mockPariId: self.mockPairId)
        let mockGenerateMyIdUseCase = MockGenerateMyIdUseCase(mockMyId: self.mockMyId)
        self.splashViewModel = SplashViewModel(coordinatorDelegate: mockCoordinatorDelegate,
                                               getMyIdUseCase: mockGetMyIdUseCase,
                                               getPairIdUseCase: mockGetPairIdUseCase,
                                               generateMyIdUseCase: mockGenerateMyIdUseCase
                                               )

        self.splashViewModel?.viewDidLoad()
        XCTAssertEqual(mockCoordinatorDelegate.result, .alreadyPaired, "Incorrect coordinator result")
        XCTAssertEqual(mockCoordinatorDelegate.myId, self.mockMyId, "Incorrect myId")
        XCTAssertEqual(mockCoordinatorDelegate.pairId, self.mockPairId, "Incorrect pairId")
    }

}
