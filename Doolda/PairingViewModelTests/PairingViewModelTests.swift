//
//  PairingViewModelTests.swift
//  PairingViewModelTests
//
//  Created by 정지승 on 2021/11/02.
//

import XCTest
import Combine

class PairingViewModelTests: XCTestCase {
    private var pairingViewModel: PairingViewModel!
    
    class MockGeneratePairIdUseCase: GeneratePairIdUseCaseProtocol {
        func generatePairId(myId: String, friendId: String) -> AnyPublisher<String, Error> {
            let future = Future<String, Error>.init { promise in
                promise(.success(UUID().uuidString))
            }
            
            return future.eraseToAnyPublisher()
        }
    }
    
    override func setUpWithError() throws {
        self.pairingViewModel = PairingViewModel(myId: UUID().uuidString, generatePairIdUseCase: MockGeneratePairIdUseCase())
    }

    override func tearDownWithError() throws {
        self.pairingViewModel = nil
    }

    func test_friend_id_is_invalid_uuid_long() {
        self.pairingViewModel.friendId = "41D7BB37-6B5E-4583-B1EA-32DCFC5D6DA7111111111"
        
        _ = self.pairingViewModel.isValidFriendId.sink { result in
            XCTAssertFalse(result)
        }
    }
    
    func test_friend_id_is_invalid_uuid_short() {
        self.pairingViewModel.friendId = ""
        
        _ = self.pairingViewModel.isValidFriendId.sink { result in
            XCTAssertFalse(result)
        }
    }
    
    func test_friend_id_is_invalid_uuid() {
        self.pairingViewModel.friendId = "12312-asd-212"
        
        _ = self.pairingViewModel.isValidFriendId.sink { result in
            XCTAssertFalse(result)
        }
    }
    
    func test_friend_id_is_valid_uuid() {
        self.pairingViewModel.friendId = "550e8400-e29b-41d4-a716-446655440000"
        
        _ = self.pairingViewModel.isValidFriendId.sink { result in
            XCTAssertTrue(result)
        }
    }
}
