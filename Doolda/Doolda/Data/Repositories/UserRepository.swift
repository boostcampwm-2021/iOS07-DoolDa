//
//  UserRepository.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/03.
//
import Combine
import Foundation

class UserRepository: UserRepositoryProtocol {
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
    
    private var disposeBag = Set<AnyCancellable>()

    
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
                    }.store(in: &self.disposeBag)
            }.store(in: &self.disposeBag)
        }.eraseToAnyPublisher()
    }
    
    
    func saveMyId(_ id: String) -> AnyPublisher<Bool, Error> {
        var disposeBag = Set<AnyCancellable>()

        return Future<Bool, Error> { promise in
            self.firebaseNetworkService
                .setDocument(path: id, in: UserRepository.userCollection, with: ["pair":""])
                .sink { completion in
                    guard case .failure(let error) = completion else {return}
                    promise(.failure(error))
                } receiveValue: { result in
                    if result {
                        self.userDefaultsPersistenceService.set(key: UserRepository.userId, value: id)
                    }
                    promise(.success(result))
                }.store(in: &disposeBag)
        }.eraseToAnyPublisher()
    }
    
    func savePairId(myId: String, friendId: String, pairId: String) -> AnyPublisher<Bool, Error> {
        <#code#>
    }
    
    func checkUserIdIsExist(_ id: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            self.firebaseNetworkService.getDocument(path: id, in: UserRepository.userCollection)
                .sink { completion in
                    guard case .failure(let error) = completion else {return}
                    if let localizedError = error as? FirebaseNetworkService.Errors,
                       localizedError == FirebaseNetworkService.Errors.nilResultError {
                        promise(.success(false))
                    }
                    promise(.failure(error))
                } receiveValue: { _ in
                    promise(.success(true))
                }.store(in: &self.disposeBag)
        }.eraseToAnyPublisher()
        
    }
    
}
