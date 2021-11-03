//
//  FirebaseNetworkProtocol.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/02.
//

import Combine
import Foundation

protocol FirebaseNetworkServiceProtocol {
    func getDocument(path: String, in collection: String) -> AnyPublisher<FirebaseDocument, Error>
    func setDocument(path: String?, in collection: String, with data: [String: Any]) -> AnyPublisher<Bool, Error> 
}
