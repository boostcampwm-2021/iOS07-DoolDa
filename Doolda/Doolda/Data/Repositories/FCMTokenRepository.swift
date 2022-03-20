//
//  FCMRepository.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/23.
//

import Combine
import Foundation

class FCMTokenRepository: FCMTokenRepositoryProtocol {
    private let firebaseNetworkService: FirebaseNetworkServiceProtocol
    
    init(firebaseNetworkService: FirebaseNetworkServiceProtocol) {
        self.firebaseNetworkService = firebaseNetworkService
    }
    
    func saveToken(for userId: DDID, with token: String) -> AnyPublisher<String, Error> {
        let fcmToken = FCMToken(token: token)
        return firebaseNetworkService
            .setDocument(collection: .fcmToken, document: userId.ddidString, dictionary: fcmToken.dictionary)
            .map { token }
            .eraseToAnyPublisher()
    }
    
    func fetchToken(for userId: DDID) -> AnyPublisher<String, Error> {
        let publisher: AnyPublisher<FCMToken, Error> = firebaseNetworkService.getDocument(collection: .fcmToken, document: userId.ddidString)
        return publisher
            .map { $0.token }
            .eraseToAnyPublisher()
    }
}
