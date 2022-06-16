//
//  LoginRepositoryProtocol.swift
//  Doolda
//
//  Created by user on 2022/06/17.
//

import Combine
import Foundation

protocol LoginRepositoryProtocol {
    func setCurrentDevice(for user: User) -> AnyPublisher<Void, Error>
    func observeLogin(for user: User) -> AnyPublisher<String, Error>
}
