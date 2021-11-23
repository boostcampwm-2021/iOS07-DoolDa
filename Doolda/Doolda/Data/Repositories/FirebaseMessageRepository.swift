//
//  FirebaseMessageRepository.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/23.
//

import Combine
import Foundation

class FirebaseMessageRepository: FirebaseMessageRepositoryProtocol {
    private let urlSessionNetworkService: URLSessionNetworkServiceProtocol
    
    init(urlSessionNetworkService: URLSessionNetworkServiceProtocol) {
        self.urlSessionNetworkService = urlSessionNetworkService
    }
    
    func sendMessage(to token: String, title: String, body: String, data: [String : String]) -> AnyPublisher<[String : Any], Error> {
        let request = FirebaseAPIs.sendFirebaseMessage(token, title, body, data)
        return self.urlSessionNetworkService.request(request)
    }
}
