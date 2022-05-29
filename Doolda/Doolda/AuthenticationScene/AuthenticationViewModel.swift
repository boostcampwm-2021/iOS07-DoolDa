//
//  AuthenticationViewModel.swift
//  Doolda
//
//  Created by Dozzing on 2022/03/30.
//

import AuthenticationServices
import Combine
import Foundation

import FirebaseAuth

protocol AuthenticationViewModelInput {
    func createAccountButtonDidTap()
    func appleLoginButtonDidTap(
        authControllerDelegate: ASAuthorizationControllerDelegate?,
        authControllerPresentationProvider: ASAuthorizationControllerPresentationContextProviding?
    )
    func emailLoginButtonDidTap(email: String, password: String)
    func signIn(withApple authorization: ASAuthorization)
}

protocol AuthenticationViewModelOutput {
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    var signUpPageRequested: PassthroughSubject<Void, Never> { get }
    var agreementPageRequested: PassthroughSubject<User, Never> { get }
    var pairingPageRequested: PassthroughSubject<User, Never> { get }
    var diaryPageRequested: PassthroughSubject<User, Never> { get }
}

typealias AuthenticationViewModelProtocol = AuthenticationViewModelInput & AuthenticationViewModelOutput

enum AuthenticationError: LocalizedError {
    case failToInitCredential
    case missingAuthDataResult

    var errorDescription: String? {
        switch self {
        case .failToInitCredential: return "fail to init credential"
        case .missingAuthDataResult: return "인증 결과가 누락되었습니다."
        }
    }
}

final class AuthenticationViewModel: AuthenticationViewModelProtocol {
    enum AuthProviders {
        static let apple = "apple.com"
    }
    
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }
    var signUpPageRequested = PassthroughSubject<Void, Never>()
    var agreementPageRequested = PassthroughSubject<User, Never>()
    var pairingPageRequested = PassthroughSubject<User, Never>()
    var diaryPageRequested = PassthroughSubject<User, Never>()

    @Published private var error: Error?

    private let sceneId: UUID
    private let authenticateUseCase: AuthenticateUseCaseProtocol
    private let appleAuthProvider: AppleAuthProvideUseCase
    private let getMyIdUseCase: GetMyIdUseCaseProtocol
    private let getUserUseCase: GetUserUseCaseProtocol
    private let createUserUseCase: CreateUserUseCaseProtocol
    
    private var rawNonce: String?
    private var cancellables: Set<AnyCancellable> = []

    init(
        sceneId: UUID,
        authenticateUseCase: AuthenticateUseCaseProtocol,
        appleAuthProvider: AppleAuthProvideUseCase,
        getMyIdUseCase: GetMyIdUseCaseProtocol,
        getUserUseCase: GetUserUseCaseProtocol,
        createUserUseCase: CreateUserUseCaseProtocol
    ) {
        self.sceneId = sceneId
        self.authenticateUseCase = authenticateUseCase
        self.appleAuthProvider = appleAuthProvider
        self.getMyIdUseCase = getMyIdUseCase
        self.getUserUseCase = getUserUseCase
        self.createUserUseCase = createUserUseCase
    }

    func appleLoginButtonDidTap(
        authControllerDelegate: ASAuthorizationControllerDelegate?,
        authControllerPresentationProvider: ASAuthorizationControllerPresentationContextProviding?
    ) {
        self.appleAuthProvider.delegate = authControllerDelegate
        self.appleAuthProvider.presentationProvider = authControllerPresentationProvider
        self.appleAuthProvider.performRequest()
    }
    
    func emailLoginButtonDidTap(email: String, password: String) {
        self.signIn(email: email, password: password)
    }
    
    func createAccountButtonDidTap() {
        self.signUpPageRequested.send()
    }
    
    func signIn(withApple authorization: ASAuthorization) {
        do {
            let credential = try appleAuthProvider.getFirebaseCredential(with: authorization)
            self.signIn(credential: credential)
        } catch {
            self.error = error
        }
    }
    
    private func signIn(credential: AuthCredential) {
        self.authenticateUseCase.signIn(credential: credential)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] authDataResult in
                self?.getUserAndValidate(with: authDataResult)
            }
            .store(in: &self.cancellables)
    }
    
    private func signIn(email: String, password: String) {
        self.authenticateUseCase.signIn(withEmail: email, password: password)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] authDataResult in
                self?.getUserAndValidate(with: authDataResult)
            }
            .store(in: &self.cancellables)
    }
    
    private func getUserAndValidate(with authDataResult: AuthDataResult?) {
        guard let user = authDataResult?.user else { return self.error = AuthenticationError.missingAuthDataResult }

        self.getMyIdUseCase.getMyId(for: user.uid)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                switch error {
                case FirebaseNetworkService.Errors.invalidDocumentSnapshot: self?.createUserAndValidate(with: user.uid)
                default: self?.error = error
                }
            } receiveValue: { [weak self] ddid in
                guard let self = self else { return }
                guard let ddid = ddid else { return self.createUserAndValidate(with: user.uid) }
                self.getUserUseCase.getUser(for: ddid)
                    .sink { completion in
                        guard case .failure(let error) = completion else { return }
                        self.error = error
                    } receiveValue: { [weak self] dooldaUser in
                        self?.validateUser(with: dooldaUser)
                    }.store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }
        
    private func createUserAndValidate(with uid: String) {
        self.createUserUseCase.create(uid: uid)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] dooldaUser in
                self?.validateUser(with: dooldaUser)
            }
            .store(in: &self.cancellables)
    }
    
    private func validateUser(with dooldaUser: User) {
        switch (dooldaUser.isAgreed, dooldaUser.isPaired) {
        case (false, _): self.agreementPageRequested.send(dooldaUser)
        case (true, false): self.pairingPageRequested.send(dooldaUser)
        case (true, true): self.diaryPageRequested.send(dooldaUser)
        }
    }
}
