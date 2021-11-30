//
//  DummyPairRepository.swift
//  EditPageUseCaseTest
//
//  Created by 김민주 on 2021/11/30.
//

import Combine
import Foundation

class DummyPairRepository: PairRepositoryProtocol {
    func deletePair(with user: User) -> AnyPublisher<User, Error> {
        return Fail(error: DummyError.notImplemented).eraseToAnyPublisher()
    }
    
    var isSuccessMode: Bool = true
    var isCheckTurnMode: Bool = false
    
    init(isSuccessMode: Bool = true) {
        self.isSuccessMode = isSuccessMode
    }
    
    func setPairId(with user: User) -> AnyPublisher<DDID, Error> {
        if isSuccessMode {
            return Just(DDID()).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Fail(error: DummyError.notImplemented).eraseToAnyPublisher()
        }
    }
    
    func setRecentlyEditedUser(with user: User) -> AnyPublisher<DDID, Error> {
        return self.isSuccessMode ? Just(DDID()).setFailureType(to: Error.self).eraseToAnyPublisher() : Fail(error: DummyError.notImplemented).eraseToAnyPublisher()
    }
    
    func fetchRecentlyEditedUser(with user: User) -> AnyPublisher<DDID, Error> {
        if self.isSuccessMode && self.isCheckTurnMode {
            return Just(user.id).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Fail(error: DummyError.failed).eraseToAnyPublisher()
        }
    }
}
