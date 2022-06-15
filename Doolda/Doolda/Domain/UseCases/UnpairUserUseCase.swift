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
        guard let pairId = user.pairId else {
            return Fail(error: Errors.userNotPaired).eraseToAnyPublisher()
        }
        
        if let friendId = user.friendId {
            return Publishers.Zip4(
                self.userRepository.setUser(user.unpairedUser()),
                self.userRepository.fetchUser(friendId)
                    .map { [weak self] friend in self?.userRepository.setUser(friend.unpairedUser()) }
                    .eraseToAnyPublisher(),
                self.pairRepository.deletePair(with: user),
                self.pageRepository.deletePages(for: pairId)
            )
            .map { user, _, _, _ in return user }
            .eraseToAnyPublisher()
        } else {
            return Publishers.Zip3(
                self.userRepository.setUser(user.unpairedUser()),
                self.pairRepository.deletePair(with: user),
                self.pageRepository.deletePages(for: pairId)
            )
            .map { user, _, _ in return user }
            .eraseToAnyPublisher()
        }
    }
}
