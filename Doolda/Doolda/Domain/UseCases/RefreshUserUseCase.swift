//
//  RefreshUserUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/06.
//

import Combine
import Foundation

protocol RefreshUserUseCaseProtocol {
    var refreshedUserPublisher: Published<User?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    func refresh(for user: User)
}

final class RefreshUserUseCase: RefreshUserUseCaseProtocol {
    var refreshedUserPublisher: Published<User?>.Publisher { self.$refreshedUser }
    var errorPublisher: Published<Error?>.Publisher { self.$error }
    
    private let userRepository: _UserRepositoryProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    @Published private var refreshedUser: User?
    @Published private var error: Error?
    
    init(userRepository: _UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func refresh(for user: User) {
        self.userRepository.fetchUser(user)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                self.error = error
            } receiveValue: { user in
                self.refreshedUser = user
            }
            .store(in: &cancellables)
    }
}
