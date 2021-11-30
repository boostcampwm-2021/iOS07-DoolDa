//
//  GetRawPageUseCaseTest.swift
//  GetRawPageUseCaseTest
//
//  Created by 정지승 on 2021/11/30.
//

import Combine
import XCTest

class GetRawPageUseCaseTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDownWithError() throws {
        self.cancellables = []
    }
    
    func testGetRawPageEntitySuccess() {
        let getRawPageUseCase = GetRawPageUseCase(rawPageRepository: DummyRawPageRepository(isSuccessMode: true))
        let pageEntity = PageEntity(
            author: User(id: DDID(), pairId: DDID(), friendId: DDID()),
            createdTime: Date(),
            updatedTime: Date(),
            jsonPath: "2001101011"
        )
        
        let expectation = expectation(description: #function)
        var errorResult: Error?
        
        getRawPageUseCase.getRawPageEntity(metaData: pageEntity)
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
    
    func testGetRawPageEntityFailure() {
        let getRawPageUseCase = GetRawPageUseCase(rawPageRepository: DummyRawPageRepository(isSuccessMode: false))
        let pageEntity = PageEntity(
            author: User(id: DDID(), pairId: DDID(), friendId: DDID()),
            createdTime: Date(),
            updatedTime: Date(),
            jsonPath: "2001101011"
        )
        
        let expectation = expectation(description: #function)
        var errorResult: Error?
        
        getRawPageUseCase.getRawPageEntity(metaData: pageEntity)
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
