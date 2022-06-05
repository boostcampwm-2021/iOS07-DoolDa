//
//  RefreshUserUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/06.
//

import Combine
import Foundation

final class RefreshUserUseCase: RefreshUserUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func refresh(for user: User) -> AnyPublisher<User, Error> {
        return self.userRepository.fetchUser(user)
    }
    
    func observe(for user: User) -> AnyPublisher<User, Error> {
        return self.userRepository.observeUser(user)
    }
}
