//
//  FCMRepository.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/23.
//

import Combine
import Foundation

class FCMTokenRepository: FCMTokenRepositoryProtocol {
    private let urlSessionNetworkService: URLSessionNetworkServiceProtocol
    
    init(urlSessionNetworkService: URLSessionNetworkServiceProtocol) {
        self.urlSessionNetworkService = urlSessionNetworkService
    }
    
    func saveToken(for userId: DDID, with token: String) -> AnyPublisher<String, Error> {
        let request = FirebaseAPIs.patchFCMTokenDocument(userId.ddidString, token)
        let publisher: AnyPublisher<FCMTokenDocument, Error> = self.urlSessionNetworkService.request(request)
        return publisher
            .compactMap { $0.token }
            .eraseToAnyPublisher()
    }
    
    func fetchToken(for userId: DDID) -> AnyPublisher<String, Error> {
        let request = FirebaseAPIs.getFCMTokenDocument(userId.ddidString)
        let publisher: AnyPublisher<FCMTokenDocument, Error> = self.urlSessionNetworkService.request(request)
        return publisher
            .compactMap { $0.token }
            .eraseToAnyPublisher()
    }
}
