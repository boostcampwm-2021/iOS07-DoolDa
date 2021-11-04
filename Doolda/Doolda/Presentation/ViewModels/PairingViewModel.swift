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
    func pairButtonDidTap()
    func refreshButtonDidTap()
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
    
    lazy var isFriendIdValid: AnyPublisher<Bool, Never> = $friendId
        .compactMap { $0 }
        .compactMap { [weak self] in return self?.isValidUUID($0) }
        .eraseToAnyPublisher()
    
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
    
    func pairButtonDidTap() {
        guard let friendId = friendId else {
            return self.error = PairingViewModelError.friendIdIsEmpty
        }

        self.generatePairIdUseCase.generatePairId(myId: self.myId, friendId: friendId)
    }
    
    func refreshButtonDidTap() {
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
            .filter { pairId in
                guard let pairId = pairId else { return false }
                return !pairId.isEmpty
            }
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
    
    private func isValidUUID(_ id: String) -> Bool {
        return id.range(of: "\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}", options: .regularExpression) != nil
    }
}
