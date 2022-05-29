//
//  SignUpViewModel.swift
//  Doolda
//
//  Created by minju kim on 2022/05/15.
//

import Combine
import Foundation

import FirebaseAuth

protocol SignUpViewModelInput {
    var emailInput: String { get set }
    var passwordInput: String { get set }
    var passwordCheckInput: String { get set }
    func signInButtonDidTap()
}

protocol SignUpViewModelOutput {
    var isEmailValidPublisher: CurrentValueSubject<Bool, Never> { get }
    var isPasswordValidPublisher: CurrentValueSubject<Bool, Never> { get }
    var isPasswordCheckValidPublisher: CurrentValueSubject<Bool, Never> { get }
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    var signInPageRequested: PassthroughSubject<Void, Never> { get }
    var agreementPageRequested: PassthroughSubject<User, Never> { get }
}

typealias SignUpViewModelProtocol = SignUpViewModelInput & SignUpViewModelOutput

enum SignUpError: LocalizedError {
    case invalidEmail
    case emailAlreadyInUse
    case invalidError

    var errorDescription: String? {
        switch self {
        case .invalidEmail: return "유효하지 않은 이메일입니다."
        case .emailAlreadyInUse: return "이미 사용하고 있는 이메일입니다."
        case .invalidError: return "에러가 발생했습니다. 다시 시도해 주십시오."
        }
    }
}

final class SignUpViewModel: SignUpViewModelProtocol {
    var isEmailValidPublisher = CurrentValueSubject<Bool, Never>(false)
    var isPasswordValidPublisher = CurrentValueSubject<Bool, Never>(false)
    var isPasswordCheckValidPublisher = CurrentValueSubject<Bool, Never>(false)
    var allInputIsValidPublisher = CurrentValueSubject<Bool, Never>(false)
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
            .compactMap { $0 }
            .flatMap { [weak self] authRataResult in
                return self?.createUserUseCase.create(uid: authRataResult.user.uid) ?? Empty<User, Error>(completeImmediately: true).eraseToAnyPublisher()
            }
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .invalidEmail:
                        self?.error = SignUpError.invalidEmail
                    case .emailAlreadyInUse:
                        self?.error = SignUpError.emailAlreadyInUse
                    default:
                        self?.error = SignUpError.invalidError
                    }
                } else {
                    self?.error = error
                }
            } receiveValue: { [weak self] user in
                self?.agreementPageRequested.send(user)
            }
            .store(in: &self.cancellables)
    }

    private func bind() {
        self.$emailInput.sink { [weak self] email in
            guard let self = self else { return }
            self.isEmailValidPublisher.send(self.checkEamilVaild(email))
            self.checkAllInputVaild()
        }
        .store(in: &self.cancellables)

        self.$passwordInput.sink { [weak self] password in
            guard let self = self else { return }
            self.isPasswordValidPublisher.send(self.checkPasswordVaild(password))
            self.isPasswordCheckValidPublisher.send(self.checkPasswordCheckVaild(self.passwordCheckInput))
            self.checkAllInputVaild()

        }
        .store(in: &self.cancellables)

        self.$passwordCheckInput.sink { [weak self] passwordCheckInput in
            guard let self = self else { return }
            self.isPasswordValidPublisher.send(self.checkPasswordVaild(self.passwordInput))
            self.isPasswordCheckValidPublisher.send(self.checkPasswordCheckVaild(passwordCheckInput))
            self.checkAllInputVaild()
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

    private func checkAllInputVaild() {
        if self.isEmailValidPublisher.value, self.isPasswordValidPublisher.value, self.isPasswordCheckValidPublisher.value {
            self.allInputIsValidPublisher.send(true)
        } else {
            self.allInputIsValidPublisher.send(false)
        }
    }
}
