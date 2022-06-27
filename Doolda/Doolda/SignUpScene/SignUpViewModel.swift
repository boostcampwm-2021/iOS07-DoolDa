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
    var isEmailValidPublisher: AnyPublisher<Bool, Never> { get }
    var isPasswordValidPublisher: AnyPublisher<Bool, Never> { get }
    var isPasswordCheckValidPublisher: AnyPublisher<Bool, Never> { get }
    var isAllInputValidPublisher: AnyPublisher<Bool, Never> { get }
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    var signInPageRequested: PassthroughSubject<Void, Never> { get }
    var agreementPageRequested: PassthroughSubject<User, Never> { get }
}

typealias SignUpViewModelProtocol = SignUpViewModelInput & SignUpViewModelOutput

enum SignUpError: LocalizedError {
    case invalidEmail
    case emailAlreadyInUse
    case weakPassword
    case invalidError

    var errorDescription: String? {
        switch self {
        case .invalidEmail: return "유효하지 않은 이메일입니다."
        case .emailAlreadyInUse: return "이미 사용하고 있는 이메일입니다."
        case .weakPassword: return "비밀번호는 영문, 숫자를 조합하여 8자리 이상이어야 합니다."
        case .invalidError: return "에러가 발생했습니다. 다시 시도해 주십시오."
        }
    }
}

final class SignUpViewModel: SignUpViewModelProtocol {
    var isEmailValidPublisher: AnyPublisher<Bool, Never> { self.$emailValidPublisher.eraseToAnyPublisher() }
    var isPasswordValidPublisher: AnyPublisher<Bool, Never> { self.$passwordValidPublisher.eraseToAnyPublisher() }
    var isPasswordCheckValidPublisher: AnyPublisher<Bool, Never> { self.$passwordCheckValidPublisher.eraseToAnyPublisher() }
    var isAllInputValidPublisher: AnyPublisher<Bool, Never> { self.$allInputValidPublisher.eraseToAnyPublisher() }
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }
    var signInPageRequested = PassthroughSubject<Void, Never>()
    var agreementPageRequested = PassthroughSubject<User, Never>()

    @Published var emailInput: String = ""
    @Published var passwordInput: String = ""
    @Published var passwordCheckInput: String = ""
    @Published private var emailValidPublisher: Bool = false
    @Published private var passwordValidPublisher: Bool = false
    @Published private var passwordCheckValidPublisher: Bool = false
    @Published private var allInputValidPublisher: Bool = false
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
                    case .weakPassword:
                        self?.error = SignUpError.weakPassword
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
            self.emailValidPublisher = self.validateEmail(email)
        }
        .store(in: &self.cancellables)
        
        Publishers.CombineLatest(self.$passwordInput, self.$passwordCheckInput)
            .sink { [weak self] (password, passwordCheck) in
                guard let self = self else { return }
                self.passwordValidPublisher = self.validatePassword(password)
                self.passwordCheckValidPublisher = self.validatePasswordCheck(password: password, passwordCheck: passwordCheck)
            }
            .store(in: &self.cancellables)
        
        Publishers.CombineLatest3(self.$emailValidPublisher, self.$passwordValidPublisher, self.$passwordCheckValidPublisher)
            .map { (isEmailValid, isPasswordValid, isPasswordCheckValid) in
                return isEmailValid && isPasswordValid && isPasswordCheckValid
            }
            .sink { [weak self] isValid in
                self?.allInputValidPublisher = isValid
            }
            .store(in: &self.cancellables)
    }

    private func validateEmail(_ email: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: email)
    }

    private func validatePassword(_ password: String) -> Bool {
        let pattern = "(?=.*[a-zA-Z])(?=.*[0-9])[\\w~!@#\\$%\\^&\\*]{8,}"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: password)
    }

    private func validatePasswordCheck(password: String, passwordCheck: String) -> Bool {
        return !passwordCheck.isEmpty && password == passwordCheck
    }
}
