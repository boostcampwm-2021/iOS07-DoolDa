//
//  DummyFirebaseMessageRepository.swift
//  ImageUseCaseTest
//
//  Created by Seunghun Yang on 2021/11/30.
//

import Combine
import Foundation

class DummyFirebaseMessageRepository: FirebaseMessageRepositoryProtocol {
    var isSuccessMode: Bool = true
    
    init(isSuccessMode: Bool) {
        self.isSuccessMode = isSuccessMode
    }
    
    func sendMessage(to token: String, title: String, body: String, data: [String : String]) -> AnyPublisher<[String : Any], Error> {
        if self.isSuccessMode {
            return Just([:]).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Fail(error: DummyError.failed).eraseToAnyPublisher()
        }
    }
}
