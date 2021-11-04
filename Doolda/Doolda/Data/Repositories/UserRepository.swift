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
    private let firebaseNetworkService: FirebaseNetworkServiceProtocol
    
    private var disposeBag = Set<AnyCancellable>()

    init(persistenceService: UserDefaultsPersistenceServiceProtocol, networkService: FirebaseNetworkServiceProtocol) {
        self.userDefaultsPersistenceService = persistenceService
        self.firebaseNetworkService = networkService
    }

    func fetchMyId() -> AnyPublisher<String, Error> {
        if let userId: String = self.userDefaultsPersistenceService.get(key: UserDefaults.Keys.userId) {
            return Just(userId).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Fail(error: UserRepositoryError.nilUserId).eraseToAnyPublisher()
        }
    }
    
    func fetchPairId(for id: String) -> AnyPublisher<String, Error> {
        return Future<String, Error> { promise in
            self.firebaseNetworkService
                .getDocument(path: id, in: FirebaseCollection.user)
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
        }.eraseToAnyPublisher()
    }
    
    func saveMyId(_ id: String) -> AnyPublisher<String, Error> {
        return Future<String, Error> { promise in
            self.firebaseNetworkService
                .setDocument(path: id, in: FirebaseCollection.user, with: ["pairId":""])
                .sink { completion in
                    guard case .failure(let error) = completion else {return}
                    promise(.failure(error))
                } receiveValue: { [weak self] result in
                    if result {
                        self?.userDefaultsPersistenceService.set(key: UserDefaults.Keys.userId, value: id)
                        promise(.success(id))
                    } else {
                        promise(.failure(UserRepositoryError.savePairIdFail))
                    }
                }.store(in: &self.disposeBag)
        }.eraseToAnyPublisher()
    }
    
    func savePairId(myId: String, friendId: String, pairId: String) -> AnyPublisher<String, Error> {
        return Future<String, Error> { promise in
            Publishers.Zip(
                self.firebaseNetworkService
                    .setDocument(path: myId, in: FirebaseCollection.user, with: ["pairId":pairId]),
                self.firebaseNetworkService
                    .setDocument(path: friendId, in: FirebaseCollection.user, with: ["pairId":pairId])
            ).sink { completion in
                guard case .failure(let error) = completion else {return}
                promise(.failure(error))
            } receiveValue: { myIdResult, friendIdResult in
                if myIdResult, friendIdResult {
                    promise(.success(pairId))
                } else {
                    promise(.failure(UserRepositoryError.savePairIdFail))
                }
            }.store(in: &self.disposeBag)
        }.eraseToAnyPublisher()
    }
    
    func checkUserIdIsExist(_ id: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            self.firebaseNetworkService.getDocument(path: id, in:FirebaseCollection.user)
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
