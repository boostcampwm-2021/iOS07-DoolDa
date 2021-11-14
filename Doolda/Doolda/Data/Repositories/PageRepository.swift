//
//  PageRepository.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/11.
//

import Combine
import Foundation

class PageRepository: PageRepositoryProtocol {
    let urlSessionNetworkService: URLSessionNetworkServiceProtocol
    
    init(urlSessionNetworkService: URLSessionNetworkServiceProtocol) {
        self.urlSessionNetworkService = urlSessionNetworkService
    }
    
    func savePage(_ page: PageEntity) -> AnyPublisher<PageEntity, Error> {
        let request = FirebaseAPIs.createPageDocument(page.author.id.ddidString, page.timeStamp, page.jsonPath, page.author.pairId!.ddidString)
        let publisher: AnyPublisher<[String: String], Error> = self.urlSessionNetworkService.request(request)
        
        return publisher
            .map { _ in page }
            .eraseToAnyPublisher()
    }
    
    // FIXME: not implemented
    func fetchPages(for pair: DDID) -> AnyPublisher<[PageEntity], Error> {
        return Just([PageEntity(author: User(id: DDID(), pairId: nil), timeStamp: Date(), jsonPath: "")]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
