//
//  RegisterUserUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Combine
import Foundation

protocol RegisterUserUseCaseProtocol {
    var registeredUserPublisher: AnyPublisher<User?, Never> { get }
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    
    func register()
}
