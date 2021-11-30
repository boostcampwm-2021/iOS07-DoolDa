//
//  DummyFCMTokenRepositoryProtocol.swift
//  ImageUseCaseTest
//
//  Created by Seunghun Yang on 2021/11/30.
//

import Combine
import Foundation

class DummyFCMTokenRepository: FCMTokenRepositoryProtocol {
    var isSuccessMode: Bool = true
    
    init(isSuccessMode: Bool) {
        self.isSuccessMode = isSuccessMode
    }
    
    func saveToken(for userId: DDID, with token: String) -> AnyPublisher<String, Error> {
        if self.isSuccessMode {
            return Just(token).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Fail(error: DummyError.failed).eraseToAnyPublisher()
        }
    }
    
    func fetchToken(for userId: DDID) -> AnyPublisher<String, Error> {
        if self.isSuccessMode {
            return Just("DUMMYTOKEN").setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Fail(error: DummyError.failed).eraseToAnyPublisher()
        }
    }
}
