//
//  UnpairUserUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Combine
import Foundation

protocol UnpairUserUseCaseProtocol {
    func unpair(user: User) -> AnyPublisher<User, Error>
}

final class UnpairUserUseCase: UnpairUserUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    private let pairRepository: PairRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol, pairRepository: PairRepositoryProtocol) {
        self.userRepository = userRepository
        self.pairRepository = pairRepository
    }
    
    func unpair(user: User) -> AnyPublisher<User, Error> {
        let resetUser = User(id: user.id, pairId: nil, friendId: nil)
        let publisher: AnyPublisher<User, Error>
        
        if let friendId = user.friendId,
           resetUser.id != friendId {
            publisher = Publishers.Zip3(
                self.userRepository.resetUser(resetUser),
                self.userRepository.resetUser(User(id: friendId, pairId: nil, friendId: nil)),
                self.pairRepository.deletePair(with: user)
            )
                .map { user, _, _ in
                    return user
                }
                .eraseToAnyPublisher()
        } else {
            publisher = Publishers.Zip(
                self.userRepository.resetUser(resetUser),
                self.pairRepository.deletePair(with: user)
            )
                .map { user, _ in
                    return user
                }
                .eraseToAnyPublisher()
        }
        
        return publisher
    }
}
