//
//  FirebaseMessageRepository.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/23.
//

import Combine
import Foundation

protocol FirebaseMessageRepositoryProtocol {
    func sendMessage(to token: String, title: String, body: String, data: [String: String]) -> AnyPublisher<[String: Any], Error>
}
