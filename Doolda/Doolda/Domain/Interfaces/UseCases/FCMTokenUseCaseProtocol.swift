//
//  FCMTokenUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Combine
import Foundation

protocol FCMTokenUseCaseProtocol {
    func setToken(for userId: DDID, with token: String) -> AnyPublisher<String, Error>
    func getToken(for userId: DDID) -> AnyPublisher<String, Error>
}
