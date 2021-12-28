//
//  UserRepository.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/03.
//
import Combine
import Foundation

enum UserRepositoryError: LocalizedError {
    case userNotLoggedIn
    case nilUserId
    case nilFriendId
    case DTOInitError
    case savePairIdFail
    
    var errorDescription: String? {
        switch self {
        case .userNotLoggedIn:
            return "유저가 로그인되어있지 않습니다."
        case .nilUserId:
            return "유저의 아이디가 존재하지 않습니다."
        case .nilFriendId:
            return "친구의 아이디가 존재하지 않습니다."
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
    
    func getMyId() -> AnyPublisher<DDID?, Never> {
        return self.fetchUser(DDID())
            .catch { _ in Just(nil).eraseToAnyPublisher() }
            .compactMap { user in
                user?.id
            }
            .eraseToAnyPublisher()
    }
    
    func setUser(_ user: User) -> AnyPublisher<User, Error> {
        guard let pairId = user.pairId else {
            let publisher: AnyPublisher<UserDocument, Error> =
            self.urlSessionNetworkService.request(FirebaseAPIs.createUserDocument(user.id.ddidString))
            return publisher.tryMap { userDocument in
                guard let newUser = userDocument.toUser() else {
                    throw UserRepositoryError.nilUserId
                }
                return newUser
            }
            .eraseToAnyPublisher()
        }
        
        guard let friendId = user.friendId else { return Fail(error: UserRepositoryError.nilFriendId).eraseToAnyPublisher() }
        let publisher: AnyPublisher<UserDocument, Error> =
        self.urlSessionNetworkService.request(FirebaseAPIs.patchUserDocument(user.id.ddidString, pairId.ddidString, friendId.ddidString))
        return publisher.tryMap { userDocument in
            guard let newUser = userDocument.toUser() else {
                throw UserRepositoryError.nilUserId
            }
            return newUser
        }
        .eraseToAnyPublisher()
    }
    
    func resetUser(_ user: User) -> AnyPublisher<User, Error> {
        let publisher: AnyPublisher<UserDocument, Error> =
        self.urlSessionNetworkService.request(FirebaseAPIs.patchUserDocument(user.id.ddidString, "", ""))
        return publisher.tryMap { userDocument in
            guard let user = userDocument.toUser() else {
                throw UserRepositoryError.nilUserId
            }
            return user
        }
        .eraseToAnyPublisher()
    }
    
    func fetchUser(_ id: DDID) -> AnyPublisher<User?, Error> {
        let publisher: AnyPublisher<UserDocument, Error> = self.urlSessionNetworkService.request(FirebaseAPIs.getUserDocuement)
        return publisher.tryMap { userDocument in
            let user = userDocument.toUser()
            return user
        }
        .eraseToAnyPublisher()
    }
    
    func fetchUser(_ user: User) -> AnyPublisher<User?, Error> {
        return self.fetchUser(user.id)
    }
}
