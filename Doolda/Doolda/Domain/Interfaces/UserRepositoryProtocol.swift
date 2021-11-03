//
//  UserRepositoryProtocol.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/02.
//

import Combine
import Foundation

protocol UserRepositoryProtocol {
    func fetchMyId() -> AnyPublisher<String, Error>
    func fetchPairId() -> AnyPublisher<String, Error>

    func saveMyId(_ id : String) -> AnyPublisher<Bool, Error>
    func savePairId(myId: String, friendId: String, pairId: String) -> AnyPublisher<Bool, Error>
    
    func checkUserIdIsExist(_ id: String) -> AnyPublisher<Bool, Error>
}
