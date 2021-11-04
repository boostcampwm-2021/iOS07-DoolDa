//
//  PairingViewModel.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/02.
//

import Combine
import Foundation

enum PairingViewModelError: LocalizedError {
    case friendIdIsEmpty
    
    var errorDescription: String? {
        switch self {
        case .friendIdIsEmpty:
            return "친구 ID가 비어있습니다."
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
    @Published var friendId: String?
    @Published var pairId: String?
    @Published var error: Error?
    
    private let myId: String
    private let generatePairIdUseCase: GeneratePairIdUseCaseProtocol
    private let refreshPairIdUseCase: RefreshPairIdUseCase
    
    private var cancellables: Set<AnyCancellable> = []
    
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
        guard let friendId = friendId else {
            return self.error = PairingViewModelError.friendIdIsEmpty
        }

        self.generatePairIdUseCase.generatePairId(myId: self.myId, friendId: friendId)
    }
    
    func refreshPairId() {
        self.refreshPairIdUseCase.refreshPairId(for: self.myId)
    }
    
    private func bind() {
        self.generatePairIdUseCase.pairedIdPublisher
            .dropFirst()
            .sink { [weak self] pairId in
                self?.pairId = pairId
            }
            .store(in: &self.cancellables)
        
        self.generatePairIdUseCase.errorPublisher
            .dropFirst()
            .sink { [weak self] error in
                self?.error = error
            }
            .store(in: &self.cancellables)
        
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
