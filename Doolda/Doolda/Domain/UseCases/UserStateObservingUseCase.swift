//
//  UserStateObservingUseCase.swift
//  Doolda
//
//  Created by user on 2022/06/17.
//

import Combine
import Foundation

final class UserStateObservingUseCase  {
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }

    private let loginRepository: LoginRepositoryProtocol

    private var cancellables: Set<AnyCancellable> = []

    @Published private var error: Error?

    static let shared = UserStateObservingUseCase(
        loginRepository: LoginRepository(
            persistenceService: UserDefaultsPersistenceService.shared,
            networkService: FirebaseNetworkService.shared)
    )

    private init(loginRepository: LoginRepositoryProtocol) {
        self.loginRepository = loginRepository
    }

    func observeCurrentDevice(for user: User) -> AnyPublisher<String, Error> {
        self.loginRepository.observeLogin(for: user)
    }
}
