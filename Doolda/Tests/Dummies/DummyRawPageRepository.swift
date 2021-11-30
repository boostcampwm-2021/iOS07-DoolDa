//
//  DummyRawPageRepository.swift
//  EditPageUseCaseTest
//
//  Created by 김민주 on 2021/11/30.
//

import Combine
import Foundation

class DummyRawPageRepository: RawPageRepositoryProtocol {
    func fetch(metaData: PageEntity) -> AnyPublisher<RawPageEntity, Error> {
        return Fail(error: DummyError.failed).eraseToAnyPublisher()
    }
    
    var isSuccessMode: Bool = true
    
    init(isSuccessMode: Bool) {
        self.isSuccessMode = isSuccessMode
    }
    
    func save(rawPage: RawPageEntity, at folder: String, with name: String) -> AnyPublisher<RawPageEntity, Error> {
        if isSuccessMode {
            return Just(rawPage)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: DummyError.failed).eraseToAnyPublisher()
        }
    }
    
    func fetch(at folder: String, with name: String) -> AnyPublisher<RawPageEntity, Error> {
        return Fail(error: DummyError.notImplemented).eraseToAnyPublisher()
    }
}
