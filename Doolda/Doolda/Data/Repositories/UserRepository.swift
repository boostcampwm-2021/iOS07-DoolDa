//
//  UserRepository.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/03.
//
import Combine
import Foundation

struct UserRepository: UserRepositoryProtocol {
    enum UserRepositoryError: LocalizedError {
        case nilUserId
        case DTOInitError
        
        var errorDescription: String? {
            switch self {
            case .nilUserId:
                return "유저의 아이디가 존재하지 않습니다."
            case .DTOInitError:
                return "DataTransferObjects가 올바르지 않습니다."
            }
        }
    }
    
    static let userCollection = "user"
    static let userId = "userId"

    private let userDefaultsPersistenceService: UserDefaultsPersistenceServiceProtocol
    private let firebaseNetworkService: FirebaseNetworkServiceProtocol
    
    init(persistenceService: UserDefaultsPersistenceServiceProtocol, networkService: FirebaseNetworkServiceProtocol) {
        self.userDefaultsPersistenceService = persistenceService
        self.firebaseNetworkService = networkService
    }

    func fetchMyId() -> AnyPublisher<String, Error> {
        if let userId: String = self.userDefaultsPersistenceService.get(key: UserRepository.userId) {
            return Result.Publisher(.success(userId)).eraseToAnyPublisher()
        } else {
            return Result.Publisher(.failure(UserRepositoryError.nilUserId)).eraseToAnyPublisher()
        }
    }
    
    func fetchPairId() -> AnyPublisher<String, Error> {
        return Future<String, Error> { promise in
            self.fetchMyId().sink { completion in
                guard case .failure(let error) = completion else {return}
                promise(.failure(error))
            } receiveValue: { userId in
                self.firebaseNetworkService
                    .getDocument(path: userId, in: UserRepository.userCollection)
                    .sink { completion in
                        guard case .failure(let error) = completion else {return}
                        promise(.failure(error))
                    } receiveValue: { document in
                        guard let user = User(data: document.data) else {
                            promise(.failure(UserRepositoryError.DTOInitError))
                            return
                        }
                        promise(.success(user.pairId))
                    }
            }
        }.eraseToAnyPublisher()
    }
    
    
    func saveMyId(_ id: String) {}
    
    func savePairId(_ id: String) {}
    
}
