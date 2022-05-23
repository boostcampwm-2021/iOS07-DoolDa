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
    func signUp(email: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?) {
        Auth.auth().createUser(withEmail: email, password: password, completion: completion)
    }
}
