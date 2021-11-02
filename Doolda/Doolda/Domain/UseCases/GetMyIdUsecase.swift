//
//  GetMyIdUsecase.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/02.
//

import Foundation
import Combine

final class GetMyIdUsecase: GetMyIdUsecaseProtocol {
    private let userRepository: UserRepositoryProtocol
        
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func getMyId() -> AnyPublisher<String, Error> {
        return userRepository.fetchMyId()
    }
}
