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
    
    func agreementButtonDidTap() {
        self.registerUserUseCase.register()
    }
    
    func deinitRequested() {
        NotificationCenter.default.post(
            name: BaseCoordinator.Notifications.coordinatorRemoveFromParent,
            object: nil,
            userInfo: [BaseCoordinator.Keys.sceneId: self.sceneId]
        )
    }
    
    private func bind() {
        self.registerUserUseCase.registeredUserPublisher
            .compactMap { $0 }
            .sink(receiveValue: { [weak self] user in
                NotificationCenter.default.post(
                    name: AgreementViewCoordinator.Notifications.userDidApproveApplicationServicePolicy,
                    object: self,
                    userInfo: [AgreementViewCoordinator.Keys.myId: user.id]
                )
            })
            .store(in: &self.cancellables)

        self.registerUserUseCase.errorPublisher
            .assign(to: &self.$error)
    }
}
