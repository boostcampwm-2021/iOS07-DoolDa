//
//  CheckMyTurnUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/16.
//

import Combine
import Foundation

final class CheckMyTurnUseCase: CheckMyTurnUseCaseProtocol {
    private let pairRepository: PairRepositoryProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(pairRepository: PairRepositoryProtocol) {
        self.pairRepository = pairRepository
    }
    
    func checkTurn(for user: User) -> AnyPublisher<Bool, Error> {
        if user.id == user.pairId {
            return Just(true).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        return Future { [weak self] promise in
            guard let self = self else { return promise(.success(false)) }
            self.pairRepository.fetchRecentlyEditedUser(with: user)
                .sink { completion in
                    guard case .failure(let error) = completion else { return }
                    promise(.failure(error))
                } receiveValue: { recentlyEditedUserId in
                    promise(.success(user.id != recentlyEditedUserId))
                }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
}
