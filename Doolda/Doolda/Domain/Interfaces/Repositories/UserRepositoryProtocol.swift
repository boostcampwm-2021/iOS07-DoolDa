//
//  UserRepositoryProtocol.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/02.
//

import Combine
import Foundation

protocol UserRepositoryProtocol {
    func setMyId(_ id: DDID) -> AnyPublisher<DDID, Never>
    func setMyId(uid: String, ddid: DDID) -> AnyPublisher<DDID, Error>
    func getMyId() -> AnyPublisher<DDID?, Never>

    func setUser(_ user: User) -> AnyPublisher<User, Error>
    func resetUser(_ user: User) -> AnyPublisher<User, Error>
    
    func fetchUser(_ id: DDID) -> AnyPublisher<User, Error>
    func fetchUser(_ user: User) -> AnyPublisher<User, Error>
}
