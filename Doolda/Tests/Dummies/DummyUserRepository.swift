//
//  DummyUserRepository.swift
//
//  EditPageUseCaseTest
//  Created by Seunghun Yang on 2021/11/30.
//
import Combine

import Foundation

class DummyUserRepository: UserRepositoryProtocol {
    var isSuccessMode: Bool = true
    var dummyMyId: DDID
    
    static let firstUserId = DDID()
    static let secondUserId = DDID()
    static let thirdUserId = DDID()
    static let fourthUserId = DDID()
    static let fifthUserId = DDID()
    static let sixthUserId = DDID()
    static let fourthAndFifthUserPairId = DDID()
    static let secondAndSixthUserPairId = DDID()
    
    private var userTable: [DDID: User] = [
        DummyUserRepository.firstUserId: User(id: DummyUserRepository.firstUserId, pairId: nil, friendId: nil),
        DummyUserRepository.secondUserId: User(id: DummyUserRepository.secondUserId, pairId: nil, friendId: nil),
        DummyUserRepository.fourthUserId: User(id: DummyUserRepository.fourthUserId, pairId: DummyUserRepository.fourthAndFifthUserPairId, friendId: DummyUserRepository.fifthUserId),
        DummyUserRepository.fifthUserId: User(id: DummyUserRepository.fifthUserId, pairId: DummyUserRepository.fourthAndFifthUserPairId, friendId: DummyUserRepository.fourthUserId),
        DummyUserRepository.sixthUserId: User(id: DummyUserRepository.sixthUserId, pairId: DummyUserRepository.secondAndSixthUserPairId, friendId: DummyUserRepository.secondUserId)
    ]
    
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
    
    func setUser(_ user: User) -> AnyPublisher<User, Error> {
        if isSuccessMode {
            self.userTable[user.id] = user
            return Just(user).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Fail(error: DummyError.failed).eraseToAnyPublisher()
        }
    }
    
    func resetUser(_ user: User) -> AnyPublisher<User, Error> {
        return Fail(error: DummyError.notImplemented).eraseToAnyPublisher()
    }
    
    func fetchUser(_ id: DDID) -> AnyPublisher<User?, Error> {
        if self.isSuccessMode {
            return Just(self.userTable[id]).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Fail(error: DummyError.failed).eraseToAnyPublisher()
        }
    }
    
    func fetchUser(_ user: User) -> AnyPublisher<User?, Error> {
        if self.isSuccessMode {
            return Just(self.userTable[user.id]).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Fail(error: DummyError.failed).eraseToAnyPublisher()
        }
    }
}
