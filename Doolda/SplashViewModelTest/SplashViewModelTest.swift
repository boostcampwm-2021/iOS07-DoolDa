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

    enum DummyError: Error {
        case dummyError
    }

    class MockCoordinatorDelegate: SplashViewCoordinatorDelegate {
        enum Result {
            case notPaired
            case alreadyPaired
        }

        var result: Result?

        func userNotPaired(myId: String) {
            self.result = .notPaired
        }

        func userAlreadyPaired(myId: String, pairId: String) {
            self.result = .alreadyPaired
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
    }

    // 내 아이디 가져오기 실패 -> 내 아이디 만들기 실패
    // 내 아이디 가져오기 실패 -> 내 아이디 만들기 성공
    // 내 아이디 가져오기 성공 -> 짝 아이디 가져오기 실패
    // 내 아이디 가져오기 성공 -> 짝 아이디 가져오기 성공

    func testParingSuccess() throws {
        let mockMyId = "00000000-0000-0000-0000-000000000001"
        let mockPairId = "00000000-0000-0000-0000-000000000002"
        let mockCoordinatorDelegate = MockCoordinatorDelegate()
        let mockGetMyIdUseCase = MockGetMyIdUseCase(mockMyId: mockMyId)
        let mockGetPairIdUseCase = MockGetPairIdUseCase(mockPariId: mockPairId)
        let mockGenerateMyIdUseCase = MockGenerateMyIdUseCase(mockMyId: mockMyId)
        self.splashViewModel = SplashViewModel(coordinatorDelegate: mockCoordinatorDelegate,
                                               getMyIdUseCase: mockGetMyIdUseCase,
                                               getPairIdUseCase: mockGetPairIdUseCase,
                                               generateMyIdUseCase: mockGenerateMyIdUseCase
                                               )

        self.splashViewModel?.viewDidLoad()
        XCTAssertEqual(mockCoordinatorDelegate.result, .alreadyPaired)
    }

}
