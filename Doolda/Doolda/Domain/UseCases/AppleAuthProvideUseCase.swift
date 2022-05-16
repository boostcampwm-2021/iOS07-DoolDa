//
//  AppleAuthProvider.swift
//  Doolda
//
//  Created by Seunghun Yang on 2022/05/07.
//

import AuthenticationServices
import Combine
import CryptoKit
import Foundation

import FirebaseAuth

final class AppleAuthProvideUseCase {
    static let identifier = "apple.com"
    
    weak var delegate: ASAuthorizationControllerDelegate?
    weak var presentationProvider: ASAuthorizationControllerPresentationContextProviding?
    
    private let rawNonce: String
    
    init() {
        self.rawNonce = Self.randomNonceString()
    }
    
    func performRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(self.rawNonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self.delegate
        authorizationController.presentationContextProvider = self.presentationProvider
        authorizationController.performRequests()
    }
    
    func getFirebaseCredential(with authorization: ASAuthorization) throws -> AuthCredential {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                  throw AuthenticatoinError.failToInitCredential
              }

        return OAuthProvider.credential(
            withProviderID: Self.identifier,
            idToken: idTokenString,
            rawNonce: self.rawNonce
        )
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }

    static func randomNonceString() -> String {
        String((0..<32).compactMap { _ in "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._".randomElement() })
    }
}
