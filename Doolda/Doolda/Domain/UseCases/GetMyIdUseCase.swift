//
//  GetMyIdUsecase.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/02.
//

import Combine
import Foundation

final class GetMyIdUseCase: GetMyIdUseCaseProtocol {
    enum Errors: LocalizedError {
        case failedToAcquireId(reason: Error?)

        var errorDescription: String? {
            switch self {
            case .failedToAcquireId(let reason):
                if let reason = reason {
                    return "\(reason.localizedDescription)(으)로 인해 ID를 얻어오는 데 실패했습니다."
                }
                return "ID를 얻어오는 데 실패하였습니다."
            }
        }
    }
    private let userRepository: UserRepositoryProtocol
        
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func getMyId(for uid: String) -> AnyPublisher<DDID?, Error> {
        return self.userRepository.getMyId(for: uid)
            .mapError { Errors.failedToAcquireId(reason: $0) }
            .eraseToAnyPublisher()
    }
}
