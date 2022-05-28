//
//  SignUpUseCase.swift
//  Doolda
//
//  Created by user on 2022/05/16.
//

import Combine
import Foundation

import FirebaseAuth

final class SignUpUseCase: SignUpUseCaseProtocol {
    enum Errors: LocalizedError {
        case failedToSignUp

        var errorDescription: String? {
            switch self {
            case .failedToSignUp:
                return "회원가입을 실패했습니다."
            }
        }
    }
    
    func signUp(email: String, password: String) -> AnyPublisher<AuthDataResult, Error> {
        return Future { promise in
            Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
                if let error = error {
                    return promise(.failure(error))
                }
                
                guard let authDataResult = authDataResult else {
                    return promise(.failure(Errors.failedToSignUp))
                }
                
                promise(.success(authDataResult))
            }
        }
        .eraseToAnyPublisher()
    }
}
