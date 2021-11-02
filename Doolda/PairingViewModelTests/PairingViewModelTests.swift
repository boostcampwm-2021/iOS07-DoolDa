//
//  PairingViewModelTests.swift
//  PairingViewModelTests
//
//  Created by 정지승 on 2021/11/02.
//

import XCTest
import Combine

class PairingViewModelTests: XCTestCase {
    private var pairingViewModel: PairingViewModelProtocol?
    
    override func setUpWithError() throws {
        self.pairingViewModel = PairingViewModel(myId: UUID())
    }

    override func tearDownWithError() throws {
        self.pairingViewModel = nil
    }

    func test_friend_id_is_invalid_uuid_long() {
        self.pairingViewModel?.changeFriend(id: "41D7BB37-6B5E-4583-B1EA-32DCFC5D6DA7111111111")
        _ = self.pairingViewModel?.errorPublisher.sink(receiveValue: { error in
            XCTAssertNotNil(error)
        })
    }
    
    func test_friend_id_is_invalid_uuid_short() {
        self.pairingViewModel?.changeFriend(id: "")
        _ = self.pairingViewModel?.errorPublisher.sink(receiveValue: { error in
            XCTAssertNotNil(error)
        })
    }
    
    func test_friend_id_is_invalid_uuid() {
        self.pairingViewModel?.changeFriend(id: "12312-asd-212")
        _ = self.pairingViewModel?.errorPublisher.sink(receiveValue: { error in
            XCTAssertNotNil(error)
        })
    }
    
    func test_friend_id_is_valid_uuid() {
        self.pairingViewModel?.changeFriend(id: "550e8400-e29b-41d4-a716-446655440000")
        _ = self.pairingViewModel?.errorPublisher.sink(receiveValue: { error in
            XCTAssertNil(error)
        })
    }
}
