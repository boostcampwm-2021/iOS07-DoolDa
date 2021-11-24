//
//  PageRepository.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/11.
//

import Combine
import Foundation
import OSLog

enum PageRepositoryError: LocalizedError {
    case userNotPaired
    case failedToFetchPages
    
    var errorDescription: String? {
        switch self {
        case .userNotPaired: return "페어링 된 유저가 없습니다."
        case .failedToFetchPages: return "페이지 패치에 실패했습니다."
        }
    }
}

class PageRepository: PageRepositoryProtocol {
    private let urlSessionNetworkService: URLSessionNetworkServiceProtocol
    private let pageEntityPersistenceService: CoreDataPageEntityPersistenceServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        urlSessionNetworkService: URLSessionNetworkServiceProtocol,
        pageEntityPersistenceService: CoreDataPageEntityPersistenceServiceProtocol
    ) {
        self.urlSessionNetworkService = urlSessionNetworkService
        self.pageEntityPersistenceService = pageEntityPersistenceService
    }
    
    func savePage(_ page: PageEntity) -> AnyPublisher<PageEntity, Error> {
        guard let pairId = page.author.pairId?.ddidString else { return Fail(error: PageRepositoryError.userNotPaired).eraseToAnyPublisher() }
        let request = FirebaseAPIs.createPageDocument(page.author.id.ddidString, page.createdTime, page.updatedTime, page.jsonPath, pairId)
        let publisher: AnyPublisher<[String: Any], Error> = self.urlSessionNetworkService.request(request)
        
        return publisher
            .map { _ in page }
            .eraseToAnyPublisher()
    }
    
    func updatePage(_ page: PageEntity) -> AnyPublisher<PageEntity, Error> {
        guard let pairId = page.author.pairId?.ddidString else { return Fail(error: PageRepositoryError.userNotPaired).eraseToAnyPublisher() }
        let request = FirebaseAPIs.patchPageDocument(page.author.id.ddidString, page.createdTime, page.updatedTime, page.jsonPath, pairId)
        let publisher: AnyPublisher<[String: Any], Error> = self.urlSessionNetworkService.request(request)
        
        return publisher
            .map { [weak self] _ -> PageEntity in
                self?.savePageToCache(pages: [page])
                return page
            }
            .eraseToAnyPublisher()
    }
    
    func fetchPages(for pair: DDID) -> AnyPublisher<[PageEntity], Error> {
        return self.fetchPageFromServer(pairId: pair, after: nil)
            .map { pages -> [PageEntity] in
                self.savePageToCache(pages: pages)
                return pages
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchPageFromServer(pairId: DDID, after: Date?) -> AnyPublisher<[PageEntity], Error> {
        let request = FirebaseAPIs.getPageDocuments(pairId.ddidString, after)
        let publisher: AnyPublisher<[[String: Any]], Error> = self.urlSessionNetworkService.request(request)
        return publisher
            .map({ dictionaries in
                var documents: [PageEntity] = []
                dictionaries.forEach { dictionary in
                    guard let documentDictionary = dictionary["document"] as? [String: Any],
                          let fieldsDictionary = documentDictionary["fields"] as? [String: [String: String]],
                          let pageDocument = PageDocument(document: fieldsDictionary),
                          let pageEntity = pageDocument.toPageEntity() else { return }
                    documents.append(pageEntity)
                }
                return documents
            })
            .eraseToAnyPublisher()
    }
    
    private func savePageToCache(pages: [PageEntity]) {
        let savePublishers = pages.map { self.pageEntityPersistenceService.savePageEntity($0) }
        
        Publishers.MergeMany(savePublishers)
            .collect()
            .sink { completion in
                guard case .failure = completion else { return }
                os_log("PageEntity caching failure", type: .fault)
            } receiveValue: { _ in }
            .store(in: &self.cancellables)
    }
}
