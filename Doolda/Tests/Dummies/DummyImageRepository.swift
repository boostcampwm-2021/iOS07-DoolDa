//
//  DummyImageRepository.swift
//  EditPageUseCaseTest
//
//  Created by Dozzing on 2021/11/30.
//

import Combine
import Foundation

class DummyImageRepository: ImageRepositoryProtocol {
    var isSuccessMode: Bool = true
    private let dummyUrl: URL

    init(isSuccessMode: Bool = true, dummyUrl: URL) {
        self.isSuccessMode = isSuccessMode
        self.dummyUrl = dummyUrl
    }

    func saveLocal(imageData: Data, fileName: String) -> AnyPublisher<URL, Error> {
        if isSuccessMode {
            return Just(dummyUrl).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Fail(error: DummyError.failed).eraseToAnyPublisher()
        }
    }

    func saveRemote(user: User, imageData: Data, fileName: String) -> AnyPublisher<URL, Error> {
        if isSuccessMode {
            return Just(dummyUrl).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Fail(error: DummyError.failed).eraseToAnyPublisher()
        }
    }
}
