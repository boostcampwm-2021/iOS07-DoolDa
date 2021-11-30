//
//  GetUserUseCaseTest.swift
//  GetUserUseCaseTest
//
//  Created by Seunghun Yang on 2021/11/30.
//

import Combine
import XCTest

class GetUserUseCaseTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        self.cancellables = []
    }
    
    func testGetUserSuccess() {
        
    }
    
    func testGetUserFailure() {
        
    }
}
