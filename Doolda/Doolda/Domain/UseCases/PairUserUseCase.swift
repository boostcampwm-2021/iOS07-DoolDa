//
//  PairUserUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/06.
//

import Combine
import Foundation

protocol PairUserUseCaseProtocol {
    var pairedUserPublisher: Published<User?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    func pair(user: User, friendId: DDID)
}
