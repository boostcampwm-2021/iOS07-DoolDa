//
//  CreateUserUseCase.swift
//  Doolda
//
//  Created by Seunghun Yang on 2022/05/16.
//

import Combine
import Foundation

// 이름이 DDID, 내용이 User
// 이름이 uid, 내용이 DDID (이걸 승지가, getMyId(for uid: String) -> AnyPublisher<DDID?, Never> 로 가져옴)

// uid에 대응되는 DDID를 올리자

final class CreateUserUseCase: CreateUserUseCaseProtocol {
    // TODO: [Dozzing] 여기 + UserRepository (uid 를 DDID로 매핑해주는것도 신경쓰셔야합니다)
    // 이름이 DDID 내용이 User, uid를 이름으로하고 DDID값을 가지는 추가 컬렉션을 만들어서 중간에 매핑하게하자. <- 중간에 매핑하는거는 승지가 한다.

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
        // uid -> DDID 매핑해서 파베에 올리고 (ddidDictionary)
        // DDID -> User 만들어서 파베에 올리기
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
