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

protocol AuthenticationViewModelInput {
    func apppleLoginButtonDidTap()
}

protocol AuthenticationViewModelOutput {
    var noncePublisher: AnyPublisher<String, Never> { get }
}

typealias AuthenticationViewModelProtocol = AuthenticationViewModelInput & AuthenticationViewModelOutput

final class AuthenticationViewModel: AuthenticationViewModelProtocol {
    
    var noncePublisher: AnyPublisher<String, Never> { self.$nonce.eraseToAnyPublisher() }
    
    @Published private var nonce: String = ""

    func apppleLoginButtonDidTap() {
        let randomNonce = self.randomNonceString()
        self.nonce = sha256(randomNonce)
    }

    private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        let nonce = self.randomNonceString()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        return request
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
//        authorizationController.performRequests()
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
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
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
