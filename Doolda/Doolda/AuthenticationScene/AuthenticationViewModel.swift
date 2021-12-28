//
//  AuthenticationViewModel.swift
//  Doolda
//
//  Created by Dozzing on 2021/12/28.
//

import Combine
import CryptoKit
import Foundation

import AuthenticationServices
import FirebaseAuth

protocol AuthenticationViewModelInput {
    func apppleLoginButtonDidTap()
    func signIn(authorization: ASAuthorization)
}

protocol AuthenticationViewModelOutput {
    var noncePublisher: AnyPublisher<String, Never> { get }
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
    var noncePublisher: AnyPublisher<String, Never> { self.$nonce.eraseToAnyPublisher() }
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }
    
    @Published private var nonce: String = ""
    @Published private var error: Error?

    private let authenticationUseCase: AuthenticationUseCaseProtocol

    init(authenticationUseCase: AuthenticationUseCaseProtocol) {
        self.authenticationUseCase = authenticationUseCase
    }

    func apppleLoginButtonDidTap() {
        let randomNonce = self.randomNonceString()
        self.nonce = sha256(randomNonce)
    }

    func signIn(authorization: ASAuthorization) {
        if self.nonce.isEmpty { return }
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                  self.error = AuthenticatoinError.failToInitCredential
                  return
              }

        let appleCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: self.nonce)

        self.authenticationUseCase.signIn(credential: appleCredential) { data, _ in
            if let user = data?.user {
                // FIXME: Coordinator와 연결
            }
        }
    }

    private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        let nonce = self.randomNonceString()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        return request
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
}
