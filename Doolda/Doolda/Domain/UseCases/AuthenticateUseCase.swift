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
    private var cancellables: Set<AnyCancellable> = []
    
    /// get currently cached FirebaseUser.
    /// if cached FirebaseUser is not exist, it returns nil
    /// if cached FirebaseUser ie exist locally, reload it to test it's validity
    func getCurrentUser() -> AnyPublisher<FirebaseAuth.User?, Error> {
        return Future<FirebaseAuth.User?, Error> { promise in
            let cachedUser = Auth.auth().currentUser
            guard let cachedUser = cachedUser else { return promise(.success(nil)) }
            cachedUser.reload() { error in
                if let error = error {
                    let firebaseError = AuthErrorCode(rawValue: error._code)
                    switch firebaseError {
                    case .userNotFound, .userTokenExpired, .invalidUserToken, .userDisabled:
                        return promise(.success(nil))
                    default:
                        return promise(.failure(error))
                    }
                }
                return promise(.success(cachedUser))
            }
        }
        .eraseToAnyPublisher()
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
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else { return }
            self.getCurrentUser()
                .sink { completion in
                    guard case .failure(let error) = completion else { return }
                    return promise(.failure(error))
                } receiveValue: { [weak self] currentUser in
                    currentUser?.delete { error in
                        if let error = error {
                            return promise(.failure(error))
                        }
                        return promise(.success(()))
                    }
                }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
}
