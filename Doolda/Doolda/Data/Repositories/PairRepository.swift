//
//  PairRepository.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/08.
//

import Combine
import Foundation

enum PairRepositoryError: LocalizedError {
    case nilUserPairId
    case DTOInitError
    case failToSetPairId
    case failToSetRecentlyEditedUser
    case failToFetchRecentlyEditedUser
    case failToDeletePair
    
    var errorDescription: String? {
        switch self {
        case .nilUserPairId:
            return "유저의 페어 아이디가 존재하지 않습니다."
        case .DTOInitError:
            return "DataTransferObjects가 올바르지 않습니다."
        case .failToSetPairId:
            return "페어 아이디 설정에 실패했습니다."
        case .failToSetRecentlyEditedUser:
            return "최근 편집자 설정에 실패했습니다."
        case .failToFetchRecentlyEditedUser:
            return "최근 편집자 정보를 가져오는데 실패했습니다."
        case .failToDeletePair:
            return "페어 아이디 삭제를 실패했습니다."
        }
    }
}

final class PairRepository: PairRepositoryProtocol {
    private let firebaseNetworkService: FirebaseNetworkServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: FirebaseNetworkServiceProtocol) {
        self.firebaseNetworkService = networkService
    }

    func setPairId(with user: User) -> AnyPublisher<DDID, Error> {
        guard let pairId = user.pairId else {
            return Fail(error: PairRepositoryError.nilUserPairId).eraseToAnyPublisher()
        }
        
        return Future { [weak self] promise in
            guard let self = self else { return promise(.failure(PairRepositoryError.failToSetPairId))}
            
            self.firebaseNetworkService.setDocument(collection: .pair, document: pairId.ddidString, dictionary: ["recentlyEditedUser": user.id.ddidString])
                .sink { completion in
                    guard case .failure(let error) = completion else { return }
                    promise(.failure(error))
                } receiveValue: { _ in
                    return promise(.success(pairId))
                }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    func setRecentlyEditedUser(with user: User) -> AnyPublisher<DDID, Error> {
        guard let pairId = user.pairId else {
            return Fail(error: PairRepositoryError.nilUserPairId).eraseToAnyPublisher()
        }
        
        return Future { [weak self] promise in
            guard let self = self else {
                return promise(.failure(PairRepositoryError.failToSetRecentlyEditedUser))
            }
            
            self.firebaseNetworkService.setDocument(collection: .pair, document: pairId.ddidString, dictionary: ["recentlyEditedUser": user.id.ddidString])
                .sink { completion in
                    guard case .failure(let error) = completion else { return }
                    promise(.failure(error))
                } receiveValue: { _ in
                    return promise(.success(pairId))
                }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    func fetchRecentlyEditedUser(with user: User) -> AnyPublisher<DDID, Error> {
        guard let pairId = user.pairId else {
            return Fail(error: PairRepositoryError.nilUserPairId).eraseToAnyPublisher()
        }
        
        return Future { [weak self] promise in
            guard let self = self else {
                return promise(.failure(PairRepositoryError.failToFetchRecentlyEditedUser))
            }
            
            self.firebaseNetworkService.getDocument(collection: .pair, document: pairId.ddidString)
                .sink { completion in
                    guard case .failure(let error) = completion else { return }
                    promise(.failure(error))
                } receiveValue: { pairDocument in
                    guard let recentlyEditedUser = pairDocument["recentlyEditedUser"] as? String,
                          let recentlyEditedUserId = DDID(from: recentlyEditedUser) else { return }
                    promise(.success(recentlyEditedUserId))
                }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    func deletePair(with user: User) -> AnyPublisher<User, Error> {
        guard let pairId = user.pairId else {
            return Fail(error: PairRepositoryError.nilUserPairId).eraseToAnyPublisher()
        }
        
        return Future { [weak self] promise in
            guard let self = self else {
                return promise(.failure(PairRepositoryError.failToDeletePair))
            }
            
            self.firebaseNetworkService.deleteDocument(collection: .pair, document: pairId.ddidString)
                .sink { completion in
                    guard case .failure(let error) = completion else { return }
                    promise(.failure(error))
                } receiveValue: { _ in
                    promise(.success(user))
                }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
}
