//
//  GetUserUseCase.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/03.
//

import Combine
import Foundation

final class GetUserUseCase: GetUserUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func getUser(for id: DDID) -> AnyPublisher<User?, Error> {
        return self.userRepository.fetchUser(id)
    }
}
