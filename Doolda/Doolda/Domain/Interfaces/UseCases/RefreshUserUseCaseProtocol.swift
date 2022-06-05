//
//  RefreshUserUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Combine
import Foundation

protocol RefreshUserUseCaseProtocol {
    var refreshedUserPublisher: AnyPublisher<User?, Never> { get }
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    
    func refresh(for user: User)
    func observe(for user: User)
}
