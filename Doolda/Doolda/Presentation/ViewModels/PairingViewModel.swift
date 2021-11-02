//
//  PairingViewModel.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/02.
//

import Combine
import Foundation

enum PairingViewModelError: LocalizedError {
    case friendIdIsNotInvalid
    case friendIdIsEmpty
    
    var errorDescription: String? {
        switch self {
        case .friendIdIsNotInvalid:
            return "유효하지 않은 친구 ID 입니다."
        case .friendIdIsEmpty:
            return "친구 ID가 비어있습니다."
        }
    }
}

protocol PairingViewModelInput {
    func changeFriend(id: String)
}

protocol PairingViewModelOutput {
    var errorPublisher: Published<Error?>.Publisher { get }
}

typealias PairingViewModelProtocol = PairingViewModelInput & PairingViewModelOutput

final class PairingViewModel: PairingViewModelProtocol {
    var errorPublisher: Published<Error?>.Publisher { $error }
    
    private let myId: UUID
    
    private var friendId: UUID?
    @Published private var error: Error?
    
    init(myId: UUID) {
        self.myId = myId
    }
    
    func changeFriend(id: String) {
        self.friendId = UUID(uuidString: id)
        
        if id.isEmpty {
            self.error = PairingViewModelError.friendIdIsEmpty
        } else if self.friendId == nil {
            self.error = PairingViewModelError.friendIdIsNotInvalid
        } else {
            self.error = nil
        }
    }
}
