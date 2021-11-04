//
//  RefreshPairIdUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/03.
//

import Combine
import Foundation

enum RefreshPairIdUseCaseError: LocalizedError {
    case pairNotExist
    
    var errorDescription: String? {
        switch self {
        case .pairNotExist:
            return "등록된 짝이 없습니다."
        }
    }
}

protocol RefreshPairIdUseCaseProtocol {
    var pairIdPublisher: Published<String?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    func refreshPairId(for id: String)
}

final class RefreshPairIdUseCase: RefreshPairIdUseCaseProtocol {
    var pairIdPublisher: Published<String?>.Publisher { self.$pairId }
    var errorPublisher: Published<Error?>.Publisher { self.$error }
    
    private let userRepository: UserRepositoryProtocol
    
    @Published private var pairId: String?
    @Published private var error: Error?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func refreshPairId(for id: String) {
        self.userRepository.fetchPairId(for: id)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] pairId in
                self?.pairId = pairId
            }
            .store(in: &self.cancellables)
    }
}
