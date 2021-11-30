//
//  DummyPageRepository.swift
//  EditPageUseCaseTest
//
//  Created by 김민주 on 2021/11/30.
//

import Combine
import Foundation

class DummyPageRepository: PageRepositoryProtocol {
    var isSuccessMode: Bool = true
    
    init(isSuccessMode: Bool) {
        self.isSuccessMode = isSuccessMode
    }
    
    func updatePage(_ page: PageEntity) -> AnyPublisher<PageEntity, Error> {
        return Fail(error: DummyError.notImplemented).eraseToAnyPublisher()
    }
    
    func savePage(_ page: PageEntity) -> AnyPublisher<PageEntity, Error> {
        if isSuccessMode {
            return Just(page)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: DummyError.failed).eraseToAnyPublisher()
        }
    }
    
    func fetchPages(for pair: DDID) -> AnyPublisher<[PageEntity], Error> {
        if isSuccessMode {
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Fail(error: DummyError.failed).eraseToAnyPublisher()
        }
    }
}
