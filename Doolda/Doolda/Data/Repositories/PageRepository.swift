//
//  PageRepository.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/11.
//

import Combine
import Foundation

class PageRepository: PageRepositoryProtocol {
    // FIXME: not implemented
    func savePage(_ page: PageEntity) -> AnyPublisher<PageEntity, Error> {
        return Just(page).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    // FIXME: not implemented
    func fetchPages(for pair: DDID) -> AnyPublisher<[PageEntity], Error> {
        return Just([PageEntity(author: User(id: DDID(), pairId: nil), timeStamp: Date(), jsonPath: "")]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
