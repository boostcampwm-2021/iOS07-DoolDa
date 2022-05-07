//
//  AuthenticateUseCase.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/12/27.
//

import AuthenticationServices
import Combine
import Foundation

import FirebaseAuth

enum AuthenticateUseCaseError: LocalizedError {
    case userNotLoggedIn
    
    var errorDescription: String? {
        switch self {
        case .userNotLoggedIn: return "로그인된 유저가 존재하지 않습니다."
        }
    }
}

final class AuthenticateUseCase: AuthenticateUseCaseProtocol {
    func getCurrentUser() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    func signIn(credential: AuthCredential) -> AnyPublisher<AuthDataResult?, Error> {
        return Future<AuthDataResult?, Error> { promise in
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    return promise(.failure(error))
                }
                return promise(.success(result))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func signIn(withEmail email: String, password: String) -> AnyPublisher<AuthDataResult?, Error> {
        return Future<AuthDataResult?, Error> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    return promise(.failure(error))
                }
                return promise(.success(result))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func delete() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            guard let currentUser = self.getCurrentUser() else { return promise(.failure(AuthenticateUseCaseError.userNotLoggedIn)) }
            currentUser.delete { error in
                if let error = error {
                    return promise(.failure(error))
                }
                return promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
}
