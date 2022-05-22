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
    case nilFriendId
    case DTOInitError
    case savePairIdFail
    
    var errorDescription: String? {
        switch self {
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
    private let firebaseNetworkService: FirebaseNetworkServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(persistenceService: UserDefaultsPersistenceServiceProtocol, networkService: FirebaseNetworkServiceProtocol) {
        self.userDefaultsPersistenceService = persistenceService
        self.firebaseNetworkService = networkService
    }
    
    func setMyId(_ id: DDID) -> AnyPublisher<DDID, Never> {
        self.userDefaultsPersistenceService.set(key: UserDefaults.Keys.userId, value: id.ddidString)
        return Just(id).eraseToAnyPublisher()
    }

    func setMyId(uid: String, ddid: DDID) -> AnyPublisher<DDID, Error> {
        let publisher = self.firebaseNetworkService.setDocument(
            collection: .ddidDictionary,
            document: uid,
            dictionary: ["ddid": ddid.ddidString]
        )
        return publisher.tryMap { _ in
            return ddid
        }
        .eraseToAnyPublisher()
    }
    
    func getMyId() -> AnyPublisher<DDID?, Never> {
        guard let userIdString: String = self.userDefaultsPersistenceService.get(key: UserDefaults.Keys.userId) else {
            return Just(nil).eraseToAnyPublisher()
        }
        return Just(DDID(from: userIdString)).eraseToAnyPublisher()
    }
    
    func getMyId(for uid: String) -> AnyPublisher<DDID?, Error> {
        return self.firebaseNetworkService.getDocument(collection: .ddidDictionary, document: uid)
            .map { data -> DDID? in
                guard let ddidString = data["ddid"] as? String,
                      let ddid = DDID(from: ddidString) else { return nil }
                return ddid
            }
            .eraseToAnyPublisher()
    }
    
    func setUser(_ user: User) -> AnyPublisher<User, Error> {
        let publisher = self.firebaseNetworkService.setDocument(collection: .user, document: user.id.ddidString, dictionary: user.dictionary)
            return publisher.tryMap { _ in
                return user
            }
            .eraseToAnyPublisher()
    }
    
    func resetUser(_ user: User) -> AnyPublisher<User, Error> {
        let resetedUser = User(id: user.id)
        let publisher = self.firebaseNetworkService.setDocument(collection: .user, document: user.id.ddidString, dictionary: resetedUser.dictionary)

        return publisher.tryMap { _ in
            return resetedUser
        }
        .eraseToAnyPublisher()
    }
    
    func fetchUser(_ id: DDID) -> AnyPublisher<User, Error> {
        let publisher: AnyPublisher<UserDataTransferObject, Error> = self.firebaseNetworkService.getDocument(collection: .user, document: id.ddidString)
        return publisher
            .map { $0.toUser(id: id) }
            .eraseToAnyPublisher()
    }
    
    func fetchUser(_ user: User) -> AnyPublisher<User, Error> {
        return self.fetchUser(user.id)
    }
}
