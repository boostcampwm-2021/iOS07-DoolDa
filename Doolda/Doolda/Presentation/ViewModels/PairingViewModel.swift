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
    case friendIsAlreadyPairedWithAnotherUser
    
    var errorDescription: String? {
        switch self {
        case .friendIdIsNotInvalid:
            return "유효하지 않은 친구 ID 입니다."
        case .friendIdIsEmpty:
            return "친구 ID가 비어있습니다."
        case .friendIsAlreadyPairedWithAnotherUser:
            return "친구가 이미 또 다른 친구와 연결되어 있습니다."
        }
    }
}

protocol PairingViewModelInput {
    func changeFriend(id: String)
    func pairUpWithUsers()
}

protocol PairingViewModelOutput {
    var pairIdPublisher: Published<UUID?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
}

typealias PairingViewModelProtocol = PairingViewModelInput & PairingViewModelOutput

final class PairingViewModel: PairingViewModelProtocol {
    var pairIdPublisher: Published<UUID?>.Publisher { self.$pairId }
    var errorPublisher: Published<Error?>.Publisher { self.$error }
    
    private let myId: UUID
    private let generatePairIdUseCase: GeneratePairIdUseCaseProtocol
    
    private var friendId: UUID?
    private var cancellables: Set<AnyCancellable> = []
    
    @Published private var pairId: UUID?
    @Published private var error: Error?
    
    init(myId: UUID, generatePairIdUseCase: GeneratePairIdUseCaseProtocol) {
        self.myId = myId
        self.generatePairIdUseCase = generatePairIdUseCase
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
    
    func pairUpWithUsers() {
        guard let friendId = friendId else {
            return self.error = PairingViewModelError.friendIdIsNotInvalid
        }
        
        self.generatePairIdUseCase.checkIfUserIdExist(id: friendId).sink { _ in
            return
        } receiveValue: { result in
            if result {
                self.error = PairingViewModelError.friendIsAlreadyPairedWithAnotherUser
            } else {
                self.generatePairIdUseCase.generatePairId(myId: self.myId, friendId: friendId).sink { _ in
                    return
                } receiveValue: { pairId in
                    self.pairId = pairId
                }
                .store(in: &self.cancellables)
            }
        }
        .store(in: &self.cancellables)
    }
}
