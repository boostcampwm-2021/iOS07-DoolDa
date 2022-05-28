//
//  SignUpViewModel.swift
//  Doolda
//
//  Created by minju kim on 2022/05/15.
//

import Combine
import Foundation

protocol SignUpViewModelInput {
    var emailInput: String { get set }
    var passwordInput: String { get set }
    var passwordCheckInput: String { get set }
    func signInButtonDidTap()

}

protocol SignUpViewModelOutput {
    var isEmailValidPublisher: PassthroughSubject<Bool, Never> { get }
    var isPasswordValidPublisher: PassthroughSubject<Bool, Never> { get }
    var isPasswordCheckValidPublisher: PassthroughSubject<Bool, Never> { get }
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    var signInPageRequested: PassthroughSubject<Void, Never> { get }
    var agreementPageRequested: PassthroughSubject<User, Never> { get }
}

typealias SignUpViewModelProtocol = SignUpViewModelInput & SignUpViewModelOutput

final class SignUpViewModel: SignUpViewModelProtocol {
    var isEmailValidPublisher = PassthroughSubject<Bool, Never>()
    var isPasswordValidPublisher = PassthroughSubject<Bool, Never>()
    var isPasswordCheckValidPublisher = PassthroughSubject<Bool, Never>()
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }
    var signInPageRequested = PassthroughSubject<Void, Never>()
    var agreementPageRequested = PassthroughSubject<User, Never>()

    @Published var emailInput: String = ""
    @Published var passwordInput: String = ""
    @Published var passwordCheckInput: String = ""
    @Published private var error: Error?

    private var cancellables: Set<AnyCancellable> = []
    private let signUpUseCase: SignUpUseCaseProtocol
    private let createUserUseCase: CreateUserUseCase

    init(
        signUpUseCase: SignUpUseCaseProtocol,
        createUserUseCase: CreateUserUseCase) {
        self.signUpUseCase = signUpUseCase
        self.createUserUseCase = createUserUseCase
        bind()
    }

    func signInButtonDidTap() {
        self.signInPageRequested.send()
    }

    func signUpButtonDidTap() {
        self.signUpUseCase.signUp(email: self.emailInput, password: self.passwordInput)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] authDataResult in
                guard let self = self else { return }
                
                self.createUserUseCase.create(uid: authDataResult.user.uid)
                    .sink(receiveCompletion: { [weak self] completion in
                        guard case .failure(let error) = completion else { return }
                        self?.error = error
                    }, receiveValue: { [weak self] user in
                        self?.agreementPageRequested.send(user)
                    })
                    .store(in: &self.cancellables)
            }
            .store(in: &self.cancellables)
    }

    private func bind() {
        self.$emailInput.sink { [weak self] email in
            guard let self = self else { return }
            self.isEmailValidPublisher.send(self.checkEamilVaild(email))
        }
        .store(in: &self.cancellables)

        self.$passwordInput.sink { [weak self] password in
            guard let self = self else { return }
            self.isPasswordValidPublisher.send(self.checkPasswordVaild(password))
            self.isPasswordCheckValidPublisher.send(self.checkPasswordCheckVaild(self.passwordCheckInput))
        }
        .store(in: &self.cancellables)

        self.$passwordCheckInput.sink { [weak self] passwordCheckInput in
            guard let self = self else { return }
            self.isPasswordValidPublisher.send(self.checkPasswordVaild(self.passwordInput))
            self.isPasswordCheckValidPublisher.send(self.checkPasswordCheckVaild(passwordCheckInput))
        }
        .store(in: &self.cancellables)
    }

    private func checkEamilVaild(_ email: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: email)
    }

    private func checkPasswordVaild(_ password: String) -> Bool {
        return true
    }

    private func checkPasswordCheckVaild(_ passwordCheck: String) -> Bool {
        return self.passwordInput == passwordCheck
    }
}
