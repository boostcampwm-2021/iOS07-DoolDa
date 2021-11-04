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
    func refreshPairId()
}

protocol PairingViewModelOutput {
    var pairId: String? { get }
    var error: Error? { get }
}

typealias PairingViewModelProtocol = PairingViewModelInput & PairingViewModelOutput

final class PairingViewModel: PairingViewModelProtocol {
    private let myId: String
    private let generatePairIdUseCase: GeneratePairIdUseCaseProtocol
    private let refreshPairIdUseCase: RefreshPairIdUseCase
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var friendId: String? = ""
    @Published var pairId: String? = ""
    @Published var error: Error?
    
    init(
        myId: String,
        generatePairIdUseCase: GeneratePairIdUseCaseProtocol,
        refreshPairIdUseCase: RefreshPairIdUseCase
    ) {
        self.myId = myId
        self.generatePairIdUseCase = generatePairIdUseCase
        self.refreshPairIdUseCase = refreshPairIdUseCase
        
        bind()
    }
    
    func pairUpWithUsers() {
        
    }
    
    func refreshPairId() {
        self.refreshPairIdUseCase.refreshPairId(for: self.myId)
    }
    
    private func bind() {
        self.refreshPairIdUseCase.pairIdPublisher
            .dropFirst()
            .sink { [weak self] pairId in
                self?.pairId = pairId
            }
            .store(in: &self.cancellables)
        
        self.refreshPairIdUseCase.errorPublisher
            .dropFirst()
            .sink { [weak self] error in
                self?.error = error
            }
            .store(in: &self.cancellables)
    }
}
