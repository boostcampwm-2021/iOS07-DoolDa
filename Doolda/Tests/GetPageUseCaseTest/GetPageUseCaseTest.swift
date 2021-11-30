//
//  GetPageUseCaseTest.swift
//  GetPageUseCaseTest
//
//  Created by 정지승 on 2021/11/30.
//

import Combine
import XCTest

class GetPageUseCaseTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDownWithError() throws {
        self.cancellables.removeAll()
    }
    
    func testGetPagesSuccess() {
        let getPageUseCase = GetPageUseCase(pageRepository: DummyPageRepository(isSuccessMode: true))
        let expectation = expectation(description: #function)
        
        var errorResult: Error?
        
        getPageUseCase.getPages(for: DDID())
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                errorResult = error
                expectation.fulfill()
            } receiveValue: { _ in
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 10)
        
        XCTAssertNil(errorResult)
    }
    
    func testGetPagesFailure() {
        let getPageUseCase = GetPageUseCase(pageRepository: DummyPageRepository(isSuccessMode: false))
        let expectation = expectation(description: #function)
        
        var errorResult: Error?
        
        getPageUseCase.getPages(for: DDID())
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                errorResult = error
                expectation.fulfill()
            } receiveValue: { _ in
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 10)
        
        XCTAssertNotNil(errorResult)
    }
}
