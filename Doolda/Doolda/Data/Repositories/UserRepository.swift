//
//  UserRepository.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/03.
//
import Combine
import Foundation

enum UserRepositoryError: LocalizedError {
    case nilUserId
    case DTOInitError
    case savePairIdFail
    
    var errorDescription: String? {
        switch self {
        case .nilUserId:
            return "유저의 아이디가 존재하지 않습니다."
        case .DTOInitError:
            return "DataTransferObjects가 올바르지 않습니다."
        case .savePairIdFail:
            return "PairID를 저장하는데 실패했습니다"
        }
    }
}

class UserRepository: UserRepositoryProtocol {
    private let userDefaultsPersistenceService: UserDefaultsPersistenceServiceProtocol
    private let urlSessionNetworkService: URLSessionNetworkServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(persistenceService: UserDefaultsPersistenceServiceProtocol, networkService: URLSessionNetworkServiceProtocol) {
        self.userDefaultsPersistenceService = persistenceService
        self.urlSessionNetworkService = networkService
    }
    
    func setMyId(_ id: DDID) -> AnyPublisher<DDID, Never> {
        self.userDefaultsPersistenceService.set(key: UserDefaults.Keys.userId, value: id.ddidString)
        return Just(id).eraseToAnyPublisher()
    }
    
    func getMyId() -> AnyPublisher<DDID?, Never> {
        guard let userIdString: String = self.userDefaultsPersistenceService.get(key: UserDefaults.Keys.userId) else {
            return Just(nil).eraseToAnyPublisher()
        }
        return Just(DDID(from: userIdString)).eraseToAnyPublisher()
    }
    
    func setUser(_ user: User) -> AnyPublisher<User, Error> {
        guard let pairId = user.pairId else {
            let publisher: AnyPublisher<UserDocument, Error> = self.urlSessionNetworkService.request(FirebaseAPIs.createUserDocument(user.id.ddidString))
            return publisher.tryMap { userDocument in
                guard let newUser = userDocument.toUser() else {
                    throw UserRepositoryError.nilUserId
                }
                return newUser
            }.eraseToAnyPublisher()
        }
        
        let publisher: AnyPublisher<UserDocument, Error> = self.urlSessionNetworkService.request(FirebaseAPIs.patchUserDocuement(user.id.ddidString, pairId.ddidString))
        return publisher.tryMap { userDocument in
            guard let newUser = userDocument.toUser() else {
                throw UserRepositoryError.nilUserId
            }
            return newUser
        }.eraseToAnyPublisher()
    }
    
    func fetchUser(_ id: DDID) -> AnyPublisher<User?, Error> {
        let publisher: AnyPublisher<UserDocument, Error> = self.urlSessionNetworkService.request(FirebaseAPIs.getUserDocuement(id.ddidString))
        return publisher.tryMap { userDocument in
            return userDocument.toUser()
        }.eraseToAnyPublisher()
    }
    
    func fetchUser(_ user: User) -> AnyPublisher<User?, Error> {
        let publisher: AnyPublisher<UserDocument, Error> = self.urlSessionNetworkService.request(FirebaseAPIs.getUserDocuement(user.id.ddidString))
        return publisher.tryMap { userDocument in
            return userDocument.toUser()
        }.eraseToAnyPublisher()
    }
}
