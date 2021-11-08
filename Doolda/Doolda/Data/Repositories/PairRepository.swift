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
    var errorDescription: String? {
        switch self {
        case .nilUserPairId:
            return "유저의 페어 아이디가 존재하지 않습니다."
        case .DTOInitError:
            return "DataTransferObjects가 올바르지 않습니다."
        }
    }
}

final class PairRepository: PairRepositoryProtocol{
    private let urlSessionNetworkService: URLSessionNetworkServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: URLSessionNetworkServiceProtocol) {
        self.urlSessionNetworkService = networkService
    }

    func setPairId(with user: User) -> AnyPublisher<DDID, Error> {
        guard let pairId = user.pairId else {
            return Fail(error: PairRepositoryError.nilUserPairId).eraseToAnyPublisher()
        }
        let publisher: AnyPublisher<PairDocument, Error> = self.urlSessionNetworkService
            .request(FirebaseAPIs.createPairDocument(user.id.ddidString, pairId.ddidString))
        return publisher.tryMap { pairDocument in
            guard let pairIdString = pairDocument.pairId,
                  let pairId = DDID(from: pairIdString) else {
                      throw PairRepositoryError.DTOInitError
                  }
            return pairId
        }
        .eraseToAnyPublisher()
    }
    
    func setRecentlyEditedUser(with user: User) -> AnyPublisher<DDID, Error> {
        <#code#>
    }
    
    func fetchRecentlyEditedUser(with user: User) -> AnyPublisher<DDID, Error> {
        <#code#>
    }
}
