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
    private var mockGetMyIdUseCase: GetMyIdUseCaseProtocol?
    private var mockGetPairIdUseCase: GetPairIdUseCaseProtocol?
    private var mockGenerateMyIdUseCase: GenerateMyIdUseCaseProtocol?

    enum DummyError: Error {
        case dummyError
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

    override func setUpWithError() throws {
        self.splashViewModel = nil
        self.mockGetMyIdUseCase = nil
        self.mockGetPairIdUseCase = nil
        self.mockGenerateMyIdUseCase = nil
    }

    // 내 식별코드 가져오고

}
