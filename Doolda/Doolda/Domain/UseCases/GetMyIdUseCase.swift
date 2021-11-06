//
//  GetMyIdUsecase.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/02.
//

import Combine
import Foundation

protocol GetMyIdUseCaseProtocol {
    func getMyId() -> AnyPublisher<DDID?, Never>
}

final class GetMyIdUseCase: GetMyIdUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
        
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func getMyId() -> AnyPublisher<DDID?, Error> {
        return userRepository.fetchMyId()
    }
}
