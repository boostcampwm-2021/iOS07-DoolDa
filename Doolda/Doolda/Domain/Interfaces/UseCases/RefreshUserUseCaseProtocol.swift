//
//  RefreshUserUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Combine
import Foundation

protocol RefreshUserUseCaseProtocol {
    func refresh(for user: User) -> AnyPublisher<User, Error>
    func observe(for user: User) -> AnyPublisher<User, Error>
}
