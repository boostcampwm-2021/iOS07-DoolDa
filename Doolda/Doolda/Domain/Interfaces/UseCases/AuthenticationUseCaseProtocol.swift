//
//  AuthenticationUseCaseProtocol.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/12/27.
//

import AuthenticationServices
import Combine
import Foundation

import FirebaseAuth

protocol AuthenticationUseCaseProtocol {
    func getCurrentUser() -> FirebaseAuth.User?
    func signIn(credential: AuthCredential, completion: ((AuthDataResult?, Error?) -> Void)?)
    func signIn(email: String, password: String) -> AnyPublisher<AuthDataResult?, Error>
    func signOut() throws
    func delete() -> AnyPublisher<Void, Error>
}
