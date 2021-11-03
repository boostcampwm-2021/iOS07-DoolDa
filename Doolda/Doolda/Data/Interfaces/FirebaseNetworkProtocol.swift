//
//  FirebaseNetworkProtocol.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/02.
//

import Combine
import Foundation

protocol FirebaseNetworkProtocol {
    func getDocument(path: String, in collection: String) -> AnyPublisher<[String: Any], Error>
}
