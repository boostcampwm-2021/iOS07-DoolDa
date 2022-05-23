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
    var serviceAgreementCheckBoxInput: Bool { get set }
    var privacyPolicyCheckBoxInput: Bool { get set }
}

protocol AgreementViewModelOutput {
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    var serviceAgreementPublisher: AnyPublisher<String?, Never> { get }
    var privacyPolicyPublisher: AnyPublisher<String?, Never> { get }
    var isPossibleToSignUpPublisher: AnyPublisher<Bool, Never> { get }
    var pairingPageRequested: PassthroughSubject<User, Never> { get }
}

typealias AgreementViewModelProtocol = AgreementViewModelInput & AgreementViewModelOutput

final class AgreementViewModel: AgreementViewModelProtocol {
    @Published var serviceAgreementCheckBoxInput: Bool = false
    @Published var privacyPolicyCheckBoxInput: Bool = false
    
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }
    var serviceAgreementPublisher: AnyPublisher<String?, Never> { self.$serviceAgreement.eraseToAnyPublisher() }
    var privacyPolicyPublisher: AnyPublisher<String?, Never> { self.$privacyPolicy.eraseToAnyPublisher() }
    var isPossibleToSignUpPublisher: AnyPublisher<Bool, Never> { self.$isPossibleToSignUp.eraseToAnyPublisher() }
    var pairingPageRequested = PassthroughSubject<User, Never>()
    
    private let sceneId: UUID
    private let user: User
    private let registerUserUseCase: RegisterUserUseCaseProtocol
    private let agreementUseCase: AgreementUseCaseProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published private var error: Error?
    @Published private var serviceAgreement: String?
    @Published private var privacyPolicy: String?
    @Published private var isPossibleToSignUp: Bool = false
    
    init(user: User,
         sceneId: UUID,
         registerUserUseCase: RegisterUserUseCaseProtocol,
         agreementUseCase: AgreementUseCaseProtocol
    ) {
        self.user = user
        self.sceneId = sceneId
        self.registerUserUseCase = registerUserUseCase
        self.agreementUseCase = agreementUseCase
        bind()
    }
    
    func viewDidLoad() {
        self.serviceAgreement = DooldaInfoType.serviceAgreement.content
        self.privacyPolicy = DooldaInfoType.privacyPolicy.content
    }
    
    func pairButtonDidTap() {
        self.agreementUseCase.setAgreementInfo(with: self.user)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] user in
                self?.pairingPageRequested.send(user)
            }
            .store(in: &self.cancellables)

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
            .sink { [weak self] user in
                guard let self = self else { return }
                self.agreementUseCase.setAgreementInfo(with: user)
                    .sink { [weak self] completion in
                        guard case .failure(let error) = completion else { return }
                        self?.error = error
                    } receiveValue: { [weak self] agreedUser in
                        NotificationCenter.default.post(
                            name: AgreementViewCoordinator.Notifications.userDidApproveApplicationServicePolicy,
                            object: self,
                            userInfo: [AgreementViewCoordinator.Keys.myId: agreedUser.id]
                        )
                    }
                    .store(in: &self.cancellables)
            }
            .store(in: &self.cancellables)
        
        Publishers.CombineLatest(self.$privacyPolicyCheckBoxInput, self.$serviceAgreementCheckBoxInput)
            .sink { (privacyPolicyInput, serviceAgreementInput) in
                self.isPossibleToSignUp = privacyPolicyInput && serviceAgreementInput
            }
            .store(in: &self.cancellables)

        self.registerUserUseCase.errorPublisher
            .assign(to: &self.$error)
    }
}
