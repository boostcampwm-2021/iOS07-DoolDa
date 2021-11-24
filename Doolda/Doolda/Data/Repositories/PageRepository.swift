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
    case failedToUpdatePage
    
    var errorDescription: String? {
        switch self {
        case .userNotPaired: return "페어링 된 유저가 없습니다."
        case .failedToFetchPages: return "페이지 패치에 실패했습니다."
        case .failedToUpdatePage: return "페이지 업데이트에 실패했습니다."
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
        return Future { [weak self] promise in
            guard let pairId = page.author.pairId?.ddidString else {
                return promise(.failure(PageRepositoryError.userNotPaired))
            }
            
            guard let self = self else {
                return promise(.failure(PageRepositoryError.failedToUpdatePage))
            }
            
            let request = FirebaseAPIs.patchPageDocument(page.author.id.ddidString, page.createdTime, page.updatedTime, page.jsonPath, pairId)
            let publisher: AnyPublisher<[String: Any], Error> = self.urlSessionNetworkService.request(request)
            
            publisher
                .sink { completion in
                    guard case .failure(let error) = completion else { return }
                    promise(.failure(error))
                } receiveValue: { [weak self] _ in
                    guard let self = self else {
                        return promise(.failure(PageRepositoryError.failedToUpdatePage))
                    }
                    
                    self.savePageToCache(pages: [page])
                        .sink { completion in
                            guard case .failure(let error) = completion else { return }
                            promise(.failure(error))
                        } receiveValue: { _ in
                            promise(.success(page))
                        }
                        .store(in: &self.cancellables)
                }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    func fetchPages(for pair: DDID) -> AnyPublisher<[PageEntity], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                return promise(.failure(PageRepositoryError.failedToFetchPages))
            }

            self.fetchPageFromServer(pairId: pair, after: nil)
                .sink(receiveCompletion: { completion in
                    guard case .failure(let error) = completion else { return }
                    promise(.failure(error))
                }, receiveValue: { [weak self] pages in
                    guard let self = self else {
                        return promise(.failure(PageRepositoryError.failedToFetchPages))
                    }

                    self.savePageToCache(pages: pages)
                        .sink(receiveCompletion: { completion in
                            guard case .failure(let error) = completion else { return }
                            promise(.failure(error))
                        }, receiveValue: { _ in
                            promise(.success(pages))
                        })
                        .store(in: &self.cancellables)
                })
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
    
    private func savePageToCache(pages: [PageEntity]) -> AnyPublisher<Void, Error> {
        let savePublishers = pages.map { self.pageEntityPersistenceService.savePageEntity($0) }
        
        return Publishers.MergeMany(savePublishers)
            .collect()
            .map { _ -> Void in () }
            .eraseToAnyPublisher()
    }
}
