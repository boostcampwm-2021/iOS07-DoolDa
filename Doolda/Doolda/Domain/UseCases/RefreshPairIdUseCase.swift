//
//  RefreshPairIdUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/03.
//

import Combine
import Foundation

enum RefreshPairIdUseCaseError: LocalizedError {
    case notExistPairId
    
    var errorDescription: String? {
        switch self {
        case .notExistPairId:
            return "등록된 짝이 없습니다."
        }
    }
}

protocol RefreshPairIdUseCaseProtocol {
    var pairedIdPublisher: Published<String?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    func refreshPairId()
}

final class RefreshPairIdUseCase: RefreshPairIdUseCaseProtocol {
    var pairedIdPublisher: Published<String?>.Publisher { self.$pairId }
    var errorPublisher: Published<Error?>.Publisher { self.$error }
    
    private let userRepository: UserRepositoryProtocol
    
    @Published private var pairId: String?
    @Published private var error: Error?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func refreshPairId() {
        self.userRepository.fetchPairId()
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] pairId in
                if pairId.isEmpty {
                    self?.error = RefreshPairIdUseCaseError.notExistPairId
                } else {
                    self?.pairId = pairId
                }
            }
            .store(in: &self.cancellables)
    }
}
