//
//  GetPairIdUseCase.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/03.
//

import Combine
import Foundation

protocol GetPairIdUseCaseProtocol {
    func getPairId(myId: String) -> AnyPublisher<String, Error>
}

class GetPairIdUseCase: GetPairIdUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func getPairId(myId: String) -> AnyPublisher<String, Error> {
        return self.userRepository.fetchPairId(for: myId)
    }
}
