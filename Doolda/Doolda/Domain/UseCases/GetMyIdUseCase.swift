//
//  GetMyIdUsecase.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/02.
//

import Combine
import Foundation

final class GetMyIdUseCase: GetMyIdUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
        
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    // FIXME: Deprecated
    func getMyId() -> AnyPublisher<DDID?, Never> {
        return userRepository.getMyId()
    }
    
    // FIXME: NOT IMPLEMENTED
    func getMyId(for uid: String) -> AnyPublisher<DDID?, Never> {
//        return userRepository.getMyId(for: uid)
        return Just(DDID()).eraseToAnyPublisher()
    }
}
