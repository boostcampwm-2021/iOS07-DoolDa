//
//  AgreementUseCase.swift
//  Doolda
//
//  Created by Seunghun Yang on 2022/05/14.
//

import Combine
import Foundation

final class AgreementUseCase: AgreementUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func setAgreementInfo(with user: User) -> AnyPublisher<User, Error> {
        let agreedUser = user.agreed()
        return userRepository.setUser(agreedUser)
    }
}
