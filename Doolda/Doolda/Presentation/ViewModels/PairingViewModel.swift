//
//  PairingViewModel.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/02.
//

import Combine
import Foundation

enum PairingViewModelError: LocalizedError {
    case friendIdIsInvalid
    case friendIdIsEmpty
    case friendIsAlreadyPairedWithAnotherUser
    
    var errorDescription: String? {
        switch self {
        case .friendIdIsInvalid:
            return "유효하지 않은 친구 ID 입니다."
        case .friendIdIsEmpty:
            return "친구 ID가 비어있습니다."
        case .friendIsAlreadyPairedWithAnotherUser:
            return "친구가 이미 또 다른 친구와 연결되어 있습니다."
        }
    }
}

protocol PairingViewModelInput {
    func pairUpWithUsers()
}

protocol PairingViewModelOutput {
    var pairId: String? { get }
    var error: Error? { get }
}

typealias PairingViewModelProtocol = PairingViewModelInput & PairingViewModelOutput

final class PairingViewModel: PairingViewModelProtocol {
    private let myId: String
    private let generatePairIdUseCase: GeneratePairIdUseCaseProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var friendId: String? = ""
    @Published var pairId: String? = ""
    @Published var error: Error?
    
    lazy var isValidFriendId: AnyPublisher<Bool, Never> = $friendId
        .map { self.isValid(UUID: $0) }
        .eraseToAnyPublisher()
    
    init(myId: String, generatePairIdUseCase: GeneratePairIdUseCaseProtocol) {
        self.myId = myId
        self.generatePairIdUseCase = generatePairIdUseCase
    }
    
    func pairUpWithUsers() {
        guard let friendId = self.friendId, isValid(UUID: friendId) else {
            return self.error = PairingViewModelError.friendIdIsInvalid
        }
        
        self.generatePairIdUseCase.generatePairId(myId: self.myId, friendId: friendId)
            .sink { [weak self] completion in
                if case let .failure(error)  = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] pairId in
                self?.pairId = pairId
            }
            .store(in: &cancellables)
    }
    
    private func isValid(UUID id: String?) -> Bool {
        return UUID(uuidString: id ?? "") != nil
    }
}
