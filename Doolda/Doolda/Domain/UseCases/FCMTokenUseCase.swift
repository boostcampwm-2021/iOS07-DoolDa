//
//  FCMTokenUseCase.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/23.
//

import Combine
import Foundation

protocol FCMTokenUseCaseProtocol {
    func setToken(for userId: DDID, with token: String) -> AnyPublisher<Void, Error>
    func getToken(for userId: DDID) -> AnyPublisher<String, Error>
}

class FCMTokenUseCase: FCMTokenUseCaseProtocol {
    private let fcmTokenRepository: FCMTokenRepositoryProtocol
    
    init(fcmTokenRepository: FCMTokenRepositoryProtocol) {
        self.fcmTokenRepository = fcmTokenRepository
    }
    
    func setToken(for userId: DDID, with token: String) -> AnyPublisher<Void, Error> {
        return self.fcmTokenRepository.saveToken(for: userId, with: token)
    }
    
    func getToken(for userId: DDID) -> AnyPublisher<String, Error> {
        return self.fcmTokenRepository.fetchToken(for: userId)
    }
}
