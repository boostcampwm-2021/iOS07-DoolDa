//
//  FCMTokenRepositoryProtocol.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/23.
//

import Combine
import Foundation

protocol FCMTokenRepositoryProtocol {
    func saveToken(for userId: DDID, with token: String) -> AnyPublisher<Void, Error>
    func fetchToken(for userId: DDID) -> AnyPublisher<String, Error>
}
