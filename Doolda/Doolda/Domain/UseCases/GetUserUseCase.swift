//
//  GetUserUseCase.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/03.
//

import Combine
import Foundation

final class GetUserUseCase: GetUserUseCaseProtocol {
    enum Errors: LocalizedError {
        case failedToAcquireUser(reason: Error?)

        var errorDescription: String? {
            switch self {
            case .failedToAcquireUser(let reason):
                if let reason = reason {
                    return "\(reason.localizedDescription)으로 인해 User를 얻어오는 데 실패했습니다."
                }
                return "유저를 얻어오는 데 실패했습니다."
            }
        }
    }

    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func getUser(for id: DDID) -> AnyPublisher<User, Error> {
        return self.userRepository.fetchUser(id)
            .mapError { Errors.failedToAcquireUser(reason: $0) }
            .eraseToAnyPublisher()
    }
}
