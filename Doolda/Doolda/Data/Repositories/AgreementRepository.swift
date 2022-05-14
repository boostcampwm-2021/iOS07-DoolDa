//
//  AgreementRepository.swift
//  Doolda
//
//  Created by Seunghun Yang on 2022/05/14.
//

import Combine
import Foundation

final class AgreementRepository: AgreementRepositoryProtocol {
    private let firebaseNetworkService: FirebaseNetworkServiceProtocol
    
    init(firebaseNetworkService: FirebaseNetworkServiceProtocol) {
        self.firebaseNetworkService = firebaseNetworkService
    }
    
    // TODO: implement this method
    func setAgreementInfo(with user: User) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
