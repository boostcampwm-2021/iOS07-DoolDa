//
//  CreateUserUseCase.swift
//  Doolda
//
//  Created by Seunghun Yang on 2022/05/16.
//

import Combine
import Foundation

final class CreateUserUseCase: CreateUserUseCaseProtocol {
    enum Errors: LocalizedError {
        case failToSetUser

        var errorDescription: String? {
            switch self {
            case .failToSetUser:
                return "User를 생성하는데 실패했습니다."
            }
        }
    }

    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    func create(uid: String) -> AnyPublisher<User, Error> {
        let ddid = DDID()
        return self.userRepository.setMyId(uid: uid, ddid: ddid)
            .flatMap { [weak self] ddid -> AnyPublisher<User, Error> in
                guard let self = self else { return Fail(error: Errors.failToSetUser).eraseToAnyPublisher() }
                let user = User(id: ddid)
                return self.userRepository.setUser(user)
            }
            .eraseToAnyPublisher()
    }
}
