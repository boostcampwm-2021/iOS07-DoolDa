//
//  DummyUserRepository.swift
//  GetMyIdUseCaseTest
//
//  Created by 김민주 on 2021/11/30.
//

import Combine
import Foundation

class DummyUserRepository: UserRepositoryProtocol {
    var isSuccessMode: Bool = true
    var dummyMyId: DDID

    init(dummyMyId: DDID, isSuccessMode: Bool = true) {
        self.dummyMyId = dummyMyId
        self.isSuccessMode = isSuccessMode
    }
    
    func setMyId(_ id: DDID) -> AnyPublisher<DDID, Never> {
        return Just(dummyMyId).eraseToAnyPublisher()
    }
    
    func getMyId() -> AnyPublisher<DDID?, Never> {
        return self.isSuccessMode ? Just(dummyMyId).eraseToAnyPublisher() : Just(nil).eraseToAnyPublisher()
    }
    
    func fetchUser(_ id: DDID) -> AnyPublisher<User?, Error> {
        return Fail(error: DummyError.notImplemented).eraseToAnyPublisher()
    }
    
    func setUser(_ user: User) -> AnyPublisher<User, Error> {
        return Fail(error: DummyError.notImplemented).eraseToAnyPublisher()
    }
    
    func resetUser(_ user: User) -> AnyPublisher<User, Error> {
        return Fail(error: DummyError.notImplemented).eraseToAnyPublisher()
    }
    
    func fetchUser(_ user: User) -> AnyPublisher<User?, Error> {
        return Fail(error: DummyError.notImplemented).eraseToAnyPublisher()
    }
}
