//
//  PairRepositoryProtocol.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/08.
//

import Combine
import Foundation

protocol PairRepositoryProtocol {
    func setPairId(with user: User) -> AnyPublisher<DDID, Error>
    
    func setRecentlyEditedUser(with user: User) -> AnyPublisher<DDID, Error>
    func fetchRecentlyEditedUser(with user: User) -> AnyPublisher<DDID, Error>
}
