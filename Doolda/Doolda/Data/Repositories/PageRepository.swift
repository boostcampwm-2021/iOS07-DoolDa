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
    
    func fetchPages(for pair: DDID) -> AnyPublisher<[PageEntity], Error> {
        let request = FirebaseAPIs.getPageDocuments(pair.ddidString)
        let publisher: AnyPublisher<[[String: Any]], Error> = self.urlSessionNetworkService.request(request)
        return publisher
            .map({ dictionaries in
                var documents: [PageEntity] = []
                dictionaries.forEach { dictionary in
                    guard let something = dictionary["document"] as? [String: Any],
                          let somethingElse = something["fields"] as? [String: [String: String]],
                          let document = PageDocument(document: somethingElse),
                          let entity = document.toPageEntity() else { return }
                    documents.append(entity)
                }
                return documents
            })
            .eraseToAnyPublisher()
    }
}
