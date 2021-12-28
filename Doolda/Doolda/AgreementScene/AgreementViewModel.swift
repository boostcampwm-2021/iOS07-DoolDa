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
    func agreementButtonDidTap()
}

protocol AgreementViewModelOutput {
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    var serviceAgreementPublisher: AnyPublisher<String?, Never> { get }
    var privacyPolicyPublisher: AnyPublisher<String?, Never> { get }
}

typealias AgreementViewModelProtocol = AgreementViewModelInput & AgreementViewModelOutput

final class AgreementViewModel: AgreementViewModelProtocol {
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }
    var serviceAgreementPublisher: AnyPublisher<String?, Never> { self.$serviceAgreement.eraseToAnyPublisher() }
    var privacyPolicyPublisher: AnyPublisher<String?, Never> { self.$privacyPolicy.eraseToAnyPublisher() }
    
    @Published private var error: Error?
    @Published private var serviceAgreement: String?
    @Published private var privacyPolicy: String?
    
    func viewDidLoad() {
        // FIXME: 서비스 정책 및 개인정보 정책에 관한 데이터 어떻게 로드할지 결정 후 작성
    }
    
    func agreementButtonDidTap() {
        // FIXME: 코디네이터 생성 후 연결
    }
}
