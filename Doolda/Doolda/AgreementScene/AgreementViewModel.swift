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
    func pairButtonDidTap()
    func deinitRequested()
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
    
    private let sceneId: UUID
    private let registerUserUseCase: RegisterUserUseCaseProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published private var error: Error?
    @Published private var serviceAgreement: String?
    @Published private var privacyPolicy: String?
    
    init(sceneId: UUID,
         registerUserUseCase: RegisterUserUseCaseProtocol) {
        self.sceneId = sceneId
        self.registerUserUseCase = registerUserUseCase
        bind()
    }
    
    func viewDidLoad() {
        // FIXME: 서비스 정책 및 개인정보 정책에 관한 데이터 어떻게 로드할지 결정 후 작성
    }
    
    func pairButtonDidTap() {
        self.registerUserUseCase.register()
    }
    
    func deinitRequested() {
        // FIXME: 코디네이터 구현 후 Notification 작성
    }
    
    private func bind() {
        self.registerUserUseCase.registeredUserPublisher
            .compactMap { $0 }
            .sink(receiveValue: { [weak self] in
                // FIXME: 코디네이터 구현 후 Notification 작성
            })
            .store(in: &self.cancellables)

        self.registerUserUseCase.errorPublisher
            .assign(to: &$error)
    }
}
