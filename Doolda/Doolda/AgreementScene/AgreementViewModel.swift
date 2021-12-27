//
//  AgreementViewModel.swift
//  Doolda
//
//  Created by 정지승 on 2021/12/28.
//

import Combine
import Foundation

protocol AgreementViewModelInput {
    func viewDidLoad()
    func nextButtonDidTap()
}

protocol AgreementViewModelOutput {
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    var serviceAgreementPublisher: AnyPublisher<String?, Never> { get }
    var privacyPolicyPublisher: AnyPublisher<String?, Never> { get }
}

typealias AgreementViewModelProtocol = AgreementViewModelInput & AgreementViewModelOutput
