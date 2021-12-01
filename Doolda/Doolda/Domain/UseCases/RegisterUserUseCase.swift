//
//  RegisterUserUseCase.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/04.
//

import Combine
import Foundation

final class RegisterUserUseCase: RegisterUserUseCaseProtocol {
    var registeredUserPublisher: AnyPublisher<User?, Never> { self.$registeredUser.eraseToAnyPublisher() }
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }
    
    private let userRepository: UserRepositoryProtocol
    private var cancellables: Set<AnyCancellable> = []
    @Published private var registeredUser: User?
    @Published private var error: Error?
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func register() {
        let id = DDID()
        let user = User(id: id)
        
        userRepository.setUser(user)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] user in
                self?.save(user: user)
            }
            .store(in: &self.cancellables)
    }
    
    private func save(user: User) {
        self.userRepository.setMyId(user.id)
            .sink { [weak self] _ in
                self?.registeredUser = user
            }
            .store(in: &self.cancellables)
    }
}
