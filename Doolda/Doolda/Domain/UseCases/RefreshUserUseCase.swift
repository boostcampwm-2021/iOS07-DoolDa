//
//  RefreshUserUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/06.
//

import Combine
import Foundation

protocol RefreshUserUseCaseProtocol {
    var refreshedUserPublisher: Published<User?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    func refresh(for user: User)
}
