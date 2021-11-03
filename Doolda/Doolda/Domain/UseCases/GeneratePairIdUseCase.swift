//
//  GeneratePairIdUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/03.
//

import Combine
import Foundation

enum GeneratePairIdUseCaseError: LocalizedError {
    case invalidUserId
    case failedPairing
    
    var errorDescription: String? {
        switch self {
        case .invalidUserId:
            return "유효하지 않은 아이디입니다."
        case .failedPairing:
            return "친구맺기에 실패했습니다."
        }
    }
}

protocol GeneratePairIdUseCaseProtocol {
    func generatePairId(myId: String, friendId: String) -> AnyPublisher<String, Error>
}

final class GeneratePairIdUseCase: GeneratePairIdUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func generatePairId(myId: String, friendId: String) -> AnyPublisher<String, Error> {
        if self.isValidId(myId) && self.isValidId(friendId) {
            let pairId = UUID().uuidString
            
            return Future<String, Error>.init { [weak self] promise in
                guard let self = self else { return }
                
                self.userRepository.savePairId(pairId).sink { completion in
                    if case let .failure(error) = completion {
                        promise(.failure(error))
                    }
                } receiveValue: { result in
                    if result {
                        promise(.success(pairId))
                    } else {
                        promise(.failure(GeneratePairIdUseCaseError.failedPairing))
                    }
                }
                .store(in: &self.cancellables)
            }
            .eraseToAnyPublisher()
        } else {
            return Future<String, Error>.init {
                $0(.failure(GeneratePairIdUseCaseError.invalidUserId))
            }
            .eraseToAnyPublisher()
        }
    }
    
    private func isValidId(_ id: String) -> Bool {
        return UUID(uuidString: id) != nil
    }
}
