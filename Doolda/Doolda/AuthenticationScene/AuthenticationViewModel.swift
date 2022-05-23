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
    func deinitRequested()
}

protocol AuthenticationViewModelOutput {
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    var signUpPageRequested: PassthroughSubject<Void, Never> { get }
    var agreementPageRequested: PassthroughSubject<User, Never> { get }
    var pairingPageRequested: PassthroughSubject<DDID, Never> { get }
    var diaryPageRequested: PassthroughSubject<User, Never> { get }
}

typealias AuthenticationViewModelProtocol = AuthenticationViewModelInput & AuthenticationViewModelOutput

enum AuthenticatoinError: LocalizedError {
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
    var pairingPageRequested = PassthroughSubject<DDID, Never>()
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
    
    func deinitRequested() {
        NotificationCenter.default.post(
            name: BaseCoordinator.Notifications.coordinatorRemoveFromParent,
            object: nil,
            userInfo: [BaseCoordinator.Keys.sceneId: self.sceneId]
        )
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
                self?.validateUser(with: authDataResult)
            }
            .store(in: &self.cancellables)
    }
    
    private func signIn(email: String, password: String) {
        self.authenticateUseCase.signIn(withEmail: email, password: password)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] authDataResult in
                self?.validateUser(with: authDataResult)
            }
            .store(in: &self.cancellables)
    }
    
    private func validateUser(with authDataResult: AuthDataResult?) {
        guard let user = authDataResult?.user else { return self.error = AuthenticatoinError.missingAuthDataResult }
        
        self.getMyIdUseCase.getMyId(for: user.uid)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] ddid in
                guard let self = self else { return }
                guard let ddid = ddid else {
                    self.createUserUseCase.create(uid: user.uid)
                        .sink { [weak self] completion in
                            guard case .failure(let error) = completion else { return }
                            self?.error = error
                        } receiveValue: { [weak self] dooldaUser in
                            self?.validateUser(with: dooldaUser)
                        }
                        .store(in: &self.cancellables)
                    return
                }
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
    
    private func validateUser(with dooldaUser: User) {
        if dooldaUser.isAgreed == false {
            self.agreementPageRequested.send(dooldaUser)
        } else if dooldaUser.pairId?.ddidString.isEmpty == false {
            self.diaryPageRequested.send(dooldaUser)
        } else {
            self.pairingPageRequested.send(dooldaUser.id)
        }
    }
}
