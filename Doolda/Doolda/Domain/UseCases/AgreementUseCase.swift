//
//  AgreementUseCase.swift
//  Doolda
//
//  Created by Seunghun Yang on 2022/05/14.
//

import Combine
import Foundation

final class AgreementUseCase: AgreementUseCaseProtocol {
    private let agreementRepository: AgreementRepositoryProtocol
    
    init(agreementRepository: AgreementRepositoryProtocol) {
        self.agreementRepository = agreementRepository
    }
    
    func setAgreementInfo(with user: User) -> AnyPublisher<Void, Error> {
        agreementRepository.setAgreementInfo(with: user)
    }
}
