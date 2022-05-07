//
//  AuthenticationViewModel.swift
//  Doolda
//
//  Created by Dozzing on 2022/03/30.
//

import AuthenticationServices
import Combine
import CryptoKit
import Foundation

import FirebaseAuth

protocol AuthenticationViewModelInput {
    func appleLoginButtonDidTap(
        authControllerDelegate: ASAuthorizationControllerDelegate?,
        authControllerPresentationProvider: ASAuthorizationControllerPresentationContextProviding?
    )
    func signIn(authorization: ASAuthorization)
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
    
    @Published private var error: Error?

    private let sceneId: UUID
    private let authenticateUseCase: AuthenticateUseCaseProtocol
    
    private var rawNonce: String?
    
    private var cancellables: Set<AnyCancellable> = []

    init(sceneId: UUID, authenticateUseCase: AuthenticateUseCaseProtocol) {
        self.sceneId = sceneId
        self.authenticateUseCase = authenticateUseCase
    }
    
    func signIn(authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                  self.error = AuthenticatoinError.failToInitCredential
                  return
              }

        let appleCredential = OAuthProvider.credential(
            withProviderID: AuthProviders.apple,
            idToken: idTokenString,
            rawNonce: self.rawNonce
        )
        
        self.authenticateUseCase.signIn(credential: appleCredential)
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
    
    // TODO: Create addtional usecase for apple authentication
    
    func appleLoginButtonDidTap(
        authControllerDelegate: ASAuthorizationControllerDelegate?,
        authControllerPresentationProvider: ASAuthorizationControllerPresentationContextProviding?
    ) {
        let rawNonce = self.randomNonceString()
        self.rawNonce = rawNonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(rawNonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = authControllerDelegate
        authorizationController.presentationContextProvider = authControllerPresentationProvider
        authorizationController.performRequests()
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func randomNonceString(with length: Int = 32) -> String {
        String((0..<length).compactMap { _ in
            "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._".randomElement()
        })
    }
}
