//
//  GetRawPageUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/18.
//

import Combine
import Foundation

protocol GetRawPageUseCaseProtocol {
    func getRawPageEntity(for pairId: DDID, jsonPath: String) -> AnyPublisher<RawPageEntity, Error>
}

class GetRawPageUseCase: GetRawPageUseCaseProtocol {
    private let rawPageRepository: RawPageRepositoryProtocol
    
    init(rawPageRepository: RawPageRepositoryProtocol) {
        self.rawPageRepository = rawPageRepository
    }
    
    func getRawPageEntity(for pairId: DDID, jsonPath: String) -> AnyPublisher<RawPageEntity, Error> {
        return self.rawPageRepository.fetch(at: pairId.ddidString, with: jsonPath)
    }
}
