//
//  GetRawPageUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/18.
//

import Combine
import Foundation

protocol GetRawPageUseCaseProtocol {
    func getRawPageEntity(metaData: PageEntity) -> AnyPublisher<RawPageEntity, Error>
}

class GetRawPageUseCase: GetRawPageUseCaseProtocol {
    private let rawPageRepository: RawPageRepositoryProtocol
    
    init(rawPageRepository: RawPageRepositoryProtocol) {
        self.rawPageRepository = rawPageRepository
    }
    
    func getRawPageEntity(metaData: PageEntity) -> AnyPublisher<RawPageEntity, Error> {
        return self.rawPageRepository.fetch(metaData: metaData)
    }
}
