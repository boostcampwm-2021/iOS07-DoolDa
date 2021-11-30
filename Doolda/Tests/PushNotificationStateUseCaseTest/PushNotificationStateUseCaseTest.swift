//
//  PushNotificationStateUseCaseTest.swift
//  PushNotificationStateUseCaseTest
//
//  Created by 김민주 on 2021/11/30.
//

import Combine
import XCTest

class PushNotificationStateUseCaseTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown(){
        self.cancellables = []
    }

    func testGetMyIdSuccess() {
        

    }
}
