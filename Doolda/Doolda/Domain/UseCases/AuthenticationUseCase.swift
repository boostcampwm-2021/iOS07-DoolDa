//
//  AuthenticationUseCase.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/12/27.
//

import AuthenticationServices
import Combine
import Foundation

import FirebaseAuth

enum AuthenticationUseCaseError: LocalizedError {
    case userNotLoggedIn
    
    var errorDescription: String? {
        switch self {
        case .userNotLoggedIn: return "로그인된 유저가 존재하지 않습니다."
        }
    }
}

final class AuthenticationUseCase: AuthenticationUseCaseProtocol {
    func getCurrentUser() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    func signIn(credential: AuthCredential, completion: ((AuthDataResult?, Error?) -> Void)?) {
        Auth.auth().signIn(with: credential, completion: completion)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func delete() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            guard let currentUser = self.getCurrentUser() else { return promise(.failure(AuthenticationUseCaseError.userNotLoggedIn)) }
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
