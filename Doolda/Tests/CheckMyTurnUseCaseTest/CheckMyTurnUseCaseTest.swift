//
//  CheckMyTurnUseCaseTest.swift
//  CheckMyTurnUseCaseTest
//
//  Created by 정지승 on 2021/11/30.
//

import Combine
import XCTest

class CheckMyTurnUseCaseTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDownWithError() throws {
        self.cancellables = []
    }
    
    func testCheckMyTurnSuccess() {
        let pairRepository = DummyPairRepository(isSuccessMode: true)
        pairRepository.isCheckTurnMode = true
        let checkMyTurnUseCase = CheckMyTurnUseCase(pairRepository: pairRepository)
        let user = User(id: DDID(), pairId: nil, friendId: nil)
        
        let expectation = expectation(description: #function)
        var errorResult: Error?
        
        checkMyTurnUseCase.checkTurn(for: user)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                errorResult = error
                expectation.fulfill()
            } receiveValue: { isMyTurn in
                XCTAssertFalse(isMyTurn)
                expectation.fulfill()
            }
            .store(in: &self.cancellables)

        waitForExpectations(timeout: 10)
        
        XCTAssertNil(errorResult)
    }
    
    func testCheckMyTurnFailure() {
        let pairRepository = DummyPairRepository(isSuccessMode: false)
        pairRepository.isCheckTurnMode = true
        let checkMyTurnUseCase = CheckMyTurnUseCase(pairRepository: pairRepository)
        let user = User(id: DDID(), pairId: nil, friendId: nil)
        
        let expectation = expectation(description: #function)
        var errorResult: Error?
        
        checkMyTurnUseCase.checkTurn(for: user)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                errorResult = error
                expectation.fulfill()
            } receiveValue: { isMyTurn in
                XCTAssertFalse(isMyTurn)
                expectation.fulfill()
            }
            .store(in: &self.cancellables)

        waitForExpectations(timeout: 10)
        
        XCTAssertNotNil(errorResult)
    }
}
