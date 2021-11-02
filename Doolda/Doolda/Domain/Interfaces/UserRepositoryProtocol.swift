//
//  UserRepositoryProtocol.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/02.
//

import Foundation
import Combine

protocol UserRepositoryProtocol {
    func fetchMyId() -> AnyPublisher<String, Error>
    func fetchPairId() -> AnyPublisher<String, Error>

    func saveMyId(_id : String)
    func save(pairId: String)
    
    func getGlobalFont() -> String
}
