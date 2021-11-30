//
//  RegisterUserUseCaseTest.swift
//  RegisterUserUseCaseTest
//
//  Created by Seunghun Yang on 2021/11/30.
//

import Combine
import XCTest

class RegisterUserUseCaseTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []
    
    override func tearDown() {
        self.cancellables = []
    }
    
    func testRegisterSuccess() {
        let userRepository = DummyUserRepository(dummyMyId: DDID(), isSuccessMode: true)
        let registerUserUseCase = RegisterUserUseCase(userRepository: userRepository)
        
        registerUserUseCase.register()
        
        let expectation = self.expectation(description: "testRegisterSuccess")
        var error: Error?
        var result: User?
        
        Publishers.Zip(registerUserUseCase.errorPublisher, registerUserUseCase.registeredUserPublisher)
            .sink { encounteredError, user in
                error = encounteredError
                result = user
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 3)
        
        XCTAssertNil(error)
        XCTAssertNotNil(result)
    }
    
    func testRegisterFailure() {
        let userRepository = DummyUserRepository(dummyMyId: DDID(), isSuccessMode: false)
        let registerUserUseCase = RegisterUserUseCase(userRepository: userRepository)
        
        registerUserUseCase.register()
        
        let expectation = self.expectation(description: "testRegisterFailure")
        var error: Error?
        var result: User?
        
        Publishers.Zip(registerUserUseCase.errorPublisher, registerUserUseCase.registeredUserPublisher)
            .sink { encounteredError, user in
                error = encounteredError
                result = user
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 3)
        
        XCTAssertNotNil(error)
        XCTAssertNil(result)
    }
}
