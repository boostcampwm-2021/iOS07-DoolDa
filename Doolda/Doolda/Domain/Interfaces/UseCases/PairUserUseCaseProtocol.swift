//
//  PairUserUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Combine
import Foundation

protocol PairUserUseCaseProtocol {
    var pairedUserPublisher: AnyPublisher<User?, Never> { get }
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    
    func pair(user: User, friendId: DDID)
    func pair(user: User)
}
