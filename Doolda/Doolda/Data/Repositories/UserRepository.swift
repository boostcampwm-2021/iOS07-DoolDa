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
        
        var errorDescription: String? {
            switch self {
            case .nilUserId:
                return "유저의 아이디가 존재하지 않습니다."
            }
        }
    }
    
    static let userId = "userId"

    private let userDefalutsPersistenceService: UserDefaultsPersistenceServiceProtocol
    
    init(userDefalutsPersistenceService: UserDefaultsPersistenceServiceProtocol) {
         self.userDefalutsPersistenceService = userDefalutsPersistenceService
     }

    func fetchMyId() -> AnyPublisher<String, Error> {
        if let userId: String = self.userDefalutsPersistenceService.get(key: UserRepository.userId) {
            return Result.Publisher(.success(userId)).eraseToAnyPublisher()
        } else {
            return Result.Publisher(.failure(UserRepositoryError.nilUserId)).eraseToAnyPublisher()
        }
    }
    
    func fetchPairId() -> AnyPublisher<String, Error> {
        
    }
    
    func saveMyId(_ id: String) {}
    
    func savePairId(_ id: String) {}
    
}
