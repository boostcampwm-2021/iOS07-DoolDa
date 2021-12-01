//
//  RefreshUserUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/06.
//

import Combine
import Foundation

final class RefreshUserUseCase: RefreshUserUseCaseProtocol {
    var refreshedUserPublisher: AnyPublisher<User?, Never> { self.$refreshedUser.eraseToAnyPublisher() }
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }
    
    private let userRepository: UserRepositoryProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    @Published private var refreshedUser: User?
    @Published private var error: Error?
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func refresh(for user: User) {
        self.userRepository.fetchUser(user)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] user in
                self?.refreshedUser = user
            }
            .store(in: &cancellables)
    }
}
