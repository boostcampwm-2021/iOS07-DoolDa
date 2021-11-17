//
//  PageRepository.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/11.
//

import Combine
import Foundation

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
        let request = FirebaseAPIs.createPageDocument(page.author.id.ddidString, page.timeStamp, page.jsonPath, pairId)
        let publisher: AnyPublisher<[String: String], Error> = self.urlSessionNetworkService.request(request)
        
        return publisher
            .map { _ in page }
            .eraseToAnyPublisher()
    }
    
    func fetchPages(for pair: DDID) -> AnyPublisher<[PageEntity], Error> {
        return Future<[PageEntity], Error> { [weak self] promise in
            guard let self = self else {
                return promise(.failure(PageRepositoryError.failedToFetchPages))
            }
            
            self.pageEntityPersistenceService.fetchPageEntities()
                .sink { completion in
                    guard case .failure(let error) = completion else { return }
                    promise(.failure(error))
                } receiveValue: { cachedPages in
                    let latestPageEntity = cachedPages.first
                    
                    self.fetchPageFromServer(pairId: pair, after: latestPageEntity?.timeStamp)
                        .sink { completion in
                            guard case .failure(let error) = completion else { return }
                            promise(.failure(error))
                        } receiveValue: { pages in
                            self.savePageToCache(pages: pages)
                            promise(.success(cachedPages + pages))
                        }
                        .store(in: &self.cancellables)
                }
                .store(in: &self.cancellables)
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
        pages.forEach {
            self.pageEntityPersistenceService.savePageEntity($0)
        }
    }
}
