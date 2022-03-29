//
//  AuthenticationViewModel.swift
//  Doolda
//
//  Created by Dozzing on 2022/03/30.
//

import Combine
import CryptoKit
import Foundation

import AuthenticationServices
import FirebaseAuth

protocol AuthenticationViewModelInput {
    func appleLoginButtonDidTap()
    func signIn(credential: AuthCredential)
}

protocol AuthenticationViewModelOutput {
    var noncePublisher: AnyPublisher<String, Never> { get }
}

typealias AuthenticationViewModelProtocol = AuthenticationViewModelInput & AuthenticationViewModelOutput

final class AuthenticationViewModel: AuthenticationViewModelProtocol {
    
    var noncePublisher: AnyPublisher<String, Never> { self.$nonce.eraseToAnyPublisher() }
    
    @Published private var nonce: String = ""
    
    func appleLoginButtonDidTap() {

    }
    
    func signIn(credential: AuthCredential) {
        
    }
    
}
