//
//  CreateUserUseCaseProtocol.swift
//  Doolda
//
//  Created by Seunghun Yang on 2022/05/16.
//

import Combine
import Foundation

protocol CreateUserUseCaseProtocol {
    func create(uid: String) -> AnyPublisher<User, Error>
}
