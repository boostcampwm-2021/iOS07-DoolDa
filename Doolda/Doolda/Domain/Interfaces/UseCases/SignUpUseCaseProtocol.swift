//
//  SignUpUseCaseProtocol.swift
//  Doolda
//
//  Created by user on 2022/05/16.
//

import Combine
import Foundation

import FirebaseAuth

protocol SignUpUseCaseProtocol {
    func signUp(email: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?)
}
