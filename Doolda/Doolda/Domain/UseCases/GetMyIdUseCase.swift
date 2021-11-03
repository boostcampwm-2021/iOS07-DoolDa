//
//  GetMyIdUsecase.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/02.
//

import Combine
import Foundation

protocol GetMyIdUseCaseProtocol {
    func getMyId() -> AnyPublisher<String, Error>
}

final class GetMyIdUseCase: GetMyIdUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
        
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func getMyId() -> AnyPublisher<String, Error> {
        return userRepository.fetchMyId()
    }
}

final class MockGetMyIdUseCase: GetMyIdUseCaseProtocol {
    func getMyId() -> AnyPublisher<String, Error> {
       return "".publisher.tryMap{_ in return ""}.eraseToAnyPublisher()
    }
}
