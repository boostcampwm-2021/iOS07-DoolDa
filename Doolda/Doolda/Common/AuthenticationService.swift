//
//  AuthenticationService.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/12/27.
//

import AuthenticationServices
import Combine
import Foundation

import FirebaseAuth

enum AuthenticationServiceErrors: LocalizedError {
    case userNotLoggedIn
    
    var errorDescription: String? {
        switch self {
        case .userNotLoggedIn: return "로그인된 유저가 존재하지 않습니다."
        }
    }
}

final class AuthenticationService {
    
    static let shared = AuthenticationService()
    
    private init() { }
    
    var currentUser: FirebaseAuth.User? { Auth.auth().currentUser }
    
    func signIn(credential: AuthCredential, completion: ((AuthDataResult?, Error?) -> Void)?) {
        Auth.auth().signIn(with: credential, completion: completion)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func delete() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            guard let currentUser = self.currentUser else { return promise(.failure(AuthenticationServiceErrors.userNotLoggedIn)) }
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
