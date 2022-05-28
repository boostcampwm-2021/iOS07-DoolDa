//
//  AuthenticateUseCaseProtocol.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/12/27.
//

import AuthenticationServices
import Combine
import Foundation

import FirebaseAuth

protocol AuthenticateUseCaseProtocol {
    func getCurrentUser() -> AnyPublisher<FirebaseAuth.User?, Error>
    func signIn(credential: AuthCredential) -> AnyPublisher<AuthDataResult?, Error>
    func signIn(withEmail email: String, password: String) -> AnyPublisher<AuthDataResult?, Error>
    func signOut() throws
    func delete() -> AnyPublisher<Void, Error>
}
