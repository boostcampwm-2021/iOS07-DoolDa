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
    func signIn(withApple authorization: ASAuthorization)
    func deinitRequested()
}

protocol AuthenticationViewModelOutput {
    var errorPublisher: AnyPublisher<Error?, Never> { get }
}

typealias AuthenticationViewModelProtocol = AuthenticationViewModelInput & AuthenticationViewModelOutput

enum AuthenticatoinError: LocalizedError {
    case failToInitCredential

    var errorDescription: String? {
        switch self {
        case .failToInitCredential:
            return "fail to init credential"
        }
    }
}

final class AuthenticationViewModel: AuthenticationViewModelProtocol {
    enum AuthProviders {
        static let apple = "apple.com"
    }
    
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }
    var signUpPageRequested = PassthroughSubject<Void, Never>()

    @Published private var error: Error?

    private let sceneId: UUID
    private let authenticateUseCase: AuthenticateUseCaseProtocol
    private let appleAuthProvider: AppleAuthProvideUseCase
    
    private var cancellables: Set<AnyCancellable> = []

    init(
        sceneId: UUID,
        authenticateUseCase: AuthenticateUseCaseProtocol,
        appleAuthProvider: AppleAuthProvideUseCase
    ) {
        self.sceneId = sceneId
        self.authenticateUseCase = authenticateUseCase
        self.appleAuthProvider = appleAuthProvider
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
            } receiveValue: { data in
                if data?.user != nil {
                    NotificationCenter.default.post(
                        name: AuthenticationViewCoordinator.Notifications.userDidSignIn,
                        object: nil
                    )
                }
            }
            .store(in: &cancellables)
    }

    func deinitRequested() {
        NotificationCenter.default.post(
            name: BaseCoordinator.Notifications.coordinatorRemoveFromParent,
            object: nil,
            userInfo: [BaseCoordinator.Keys.sceneId: self.sceneId]
        )
    }

    func createAccountButtonDidTap() {
        self.signUpPageRequested.send()
    }

    // TODO: Create addtional usecase for apple authentication
    
    func appleLoginButtonDidTap(
        authControllerDelegate: ASAuthorizationControllerDelegate?,
        authControllerPresentationProvider: ASAuthorizationControllerPresentationContextProviding?
    ) {
        self.appleAuthProvider.delegate = authControllerDelegate
        self.appleAuthProvider.presentationProvider = authControllerPresentationProvider
        self.appleAuthProvider.performRequest()
    }
}
