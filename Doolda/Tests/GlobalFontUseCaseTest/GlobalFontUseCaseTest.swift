//
//  GlobalFontUseCaseTest.swift
//  GlobalFontUseCaseTest
//
//  Created by 김민주 on 2021/11/30.
//

import Combine
import XCTest

class GlobalFontUseCaseTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown(){
        self.cancellables = []
    }
    
    func testSetGlobalFontSuccess() {
        let globalFontUseCase = GlobalFontUseCase(
            globalFontRepository: DummyGlobalFontRepository()
        )
        
        let targetFontName = "testFontName"
        let expectation = self.expectation(description: #function)

        NotificationCenter.default.publisher(for: GlobalFontUseCase.Notifications.globalFontDidSet, object: nil)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        globalFontUseCase.setGlobalFont(with: targetFontName)
        
        waitForExpectations(timeout: 5)
        XCTAssertEqual(targetFontName, UIFont.globalFontFamily)
    }
    
    func testSaveGlobalFontSuccess() {
        let dummyGlobalFontRepository = DummyGlobalFontRepository()
        let globalFontUseCase = GlobalFontUseCase(
            globalFontRepository: dummyGlobalFontRepository
        )
        
        let targetFontName = "testFontName"

        globalFontUseCase.saveGlobalFont(as: targetFontName)
        
        XCTAssertEqual(targetFontName, dummyGlobalFontRepository.dummyGlobalFontName)
    }
    