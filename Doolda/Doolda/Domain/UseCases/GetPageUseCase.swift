//
//  GetPageUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/16.
//

import Combine
import Foundation

protocol GetPageUseCaseProtocol {
    func getPages(for pair: DDID) -> AnyPublisher<[PageEntity], Error>
}

class GetPageUseCase: GetPageUseCaseProtocol {
    func getPages(for pair: DDID) -> AnyPublisher<[PageEntity], Error> {
        // FIXME : 페이지 정보를 가져올 수 있도록 구현
        return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
