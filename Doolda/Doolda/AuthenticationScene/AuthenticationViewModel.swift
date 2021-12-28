//
//  AuthenticationViewModel.swift
//  Doolda
//
//  Created by Dozzing on 2021/12/28.
//

import Foundation

protocol AuthenticationViewModelInput {
    func apppleLoginButtonDidTap()
}

protocol AuthenticationViewModelOutput {

}

typealias AuthenticationViewModelProtocol = AuthenticationViewModelInput & AuthenticationViewModelOutput

final class AuthenticationViewModel: AuthenticationViewModelProtocol {
    func apppleLoginButtonDidTap() {

    }
}
