//
//  AgreementUseCaseProtocol.swift
//  Doolda
//
//  Created by Seunghun Yang on 2022/05/14.
//

import Combine
import Foundation

protocol AgreementUseCaseProtocol {
    func setAgreementInfo(with user: User) -> AnyPublisher<Void, Error>
}
