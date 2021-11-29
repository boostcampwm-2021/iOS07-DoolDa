//
//  GetPageUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/16.
//

import Combine
import Foundation

final class GetPageUseCase: GetPageUseCaseProtocol {
    private let pageRepository: PageRepositoryProtocol
    
    init(pageRepository: PageRepositoryProtocol) {
        self.pageRepository = pageRepository
    }
    
    func getPages(for pair: DDID) -> AnyPublisher<[PageEntity], Error> {
        return self.pageRepository.fetchPages(for: pair)
    }
}
