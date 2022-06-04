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
    enum Errors: LocalizedError {
        case userNotPaired
        
        var errorDescription: String? {
            switch self {
            case .userNotPaired:
                return "연결된 친구가 없습니다."
            }
        }
    }
    
    private let userRepository: UserRepositoryProtocol
    private let pairRepository: PairRepositoryProtocol
    private let pageRepository: PageRepositoryProtocol
    
    init(
        userRepository: UserRepositoryProtocol,
        pairRepository: PairRepositoryProtocol,
        pageRepository: PageRepositoryProtocol
    ) {
        self.userRepository = userRepository
        self.pairRepository = pairRepository
        self.pageRepository = pageRepository
    }
    
    func unpair(user: User) -> AnyPublisher<User, Error> {
        guard let pairId = user.pairId else { return Fail(error: Errors.userNotPaired).eraseToAnyPublisher() }
        
        let resetUser = User(id: user.id, pairId: nil, friendId: nil)
        let publisher: AnyPublisher<User, Error>
        
        if let friendId = user.friendId,
           resetUser.id != friendId {
            publisher = Publishers.Zip4(
                self.userRepository.resetUser(resetUser),
                self.userRepository.resetUser(User(id: friendId, pairId: nil, friendId: nil)),
                self.pairRepository.deletePair(with: user),
                self.pageRepository.deletePages(for: pairId)
            )
                .map { user, _, _, _ in
                    return user
                }
                .eraseToAnyPublisher()
        } else {
            publisher = Publishers.Zip3(
                self.userRepository.resetUser(resetUser),
                self.pairRepository.deletePair(with: user),
                self.pageRepository.deletePages(for: pairId)
            )
                .map { user, _, _ in
                    return user
                }
                .eraseToAnyPublisher()
        }
        
        return publisher
    }
}
