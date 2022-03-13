//
//  GetUserUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Combine
import Foundation

protocol GetUserUseCaseProtocol {
    func getUser(for id: DDID) -> AnyPublisher<User, Error>
}
