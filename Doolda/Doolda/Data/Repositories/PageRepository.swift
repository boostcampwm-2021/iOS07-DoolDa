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
    case failedToSavePage
    case failedToDeletePage
    case tempError
    
    var errorDescription: String? {
        switch self {
        case .userNotPaired: return "페어링 된 유저가 없습니다."
        case .failedToFetchPages: return "페이지 패치에 실패했습니다."
        case .failedToUpdatePage: return "페이지 업데이트에 실패했습니다."
        case .failedToSavePage: return "페이지 저장에 실패했습니다."
        case .failedToDeletePage: return "페이지 삭제에 실패했습니다."
        case .tempError: return "임시"
        }
    }
}

class PageRepository: PageRepositoryProtocol {
    private let pageEntityPersistenceService: CoreDataPageEntityPersistenceServiceProtocol
    private let firebaseNetworkService: FirebaseNetworkServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        networkService: FirebaseNetworkServiceProtocol,
        pageEntityPersistenceService: CoreDataPageEntityPersistenceServiceProtocol
    ) {
        self.firebaseNetworkService = networkService
        self.pageEntityPersistenceService = pageEntityPersistenceService
    }
    
    func savePage(_ page: PageEntity) -> AnyPublisher<PageEntity, Error> {
        guard let pairId = page.author.pairId?.ddidString else { return Fail(error: PageRepositoryError.userNotPaired).eraseToAnyPublisher() }
        
        return Future { [weak self] promise in
            guard let self = self else { return promise(.failure(PageRepositoryError.failedToSavePage)) }
            
            self.firebaseNetworkService.setDocument(collection: .page, document: pairId + page.jsonPath, transferable: page)
                .sink { completion in
                    guard case .failure(let error) = completion else { return }
                    promise(.failure(error))
                } receiveValue: { _ in
                    promise(.success(page))
                }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    func updatePage(_ page: PageEntity) -> AnyPublisher<PageEntity, Error> {
        guard let pairId = page.author.pairId?.ddidString else { return Fail(error: PageRepositoryError.userNotPaired).eraseToAnyPublisher() }
        
        return Future { [weak self] promise in
            guard let self = self else { return promise(.failure(PageRepositoryError.failedToUpdatePage)) }
            
            self.firebaseNetworkService.setDocument(collection: .page, document: pairId + page.jsonPath, transferable: page)
                .sink { completion in
                    guard case .failure(let error) = completion else { return }
                    promise(.failure(error))
                } receiveValue: { [weak self] _ in
                    guard let self = self else { return promise(.failure(PageRepositoryError.failedToUpdatePage)) }
                    
                    // FIXME: - Firebase 내부적으로 Offline Data Access를 위해 캐싱 처리를 하는것 같아 보입니다. 따라서, PageEntity에 대한 추가적인 캐싱이 불필요해보여요
                    // https://firebase.google.com/docs/firestore/manage-data/enable-offline
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
            guard let self = self else { return promise(.failure(PageRepositoryError.failedToFetchPages)) }
            let conditions = ["pairId": pair.ddidString]
            
            let firebaseNetworkServicePublisher: AnyPublisher<[PageEntity], Error> = self.firebaseNetworkService.getDocuments(
                collection: .page,
                conditions: conditions
            )
            
            firebaseNetworkServicePublisher
                .sink { completion in
                    guard case .failure(let error) = completion else { return }
                    promise(.failure(error))
                } receiveValue: { [weak self] pages in
                    guard let self = self else {
                        return promise(.failure(PageRepositoryError.failedToFetchPages))
                    }

                    // FIXME: - Firebase 내부적으로 Offline Data Access를 위해 캐싱 처리를 하는것 같아  보입니다. 따라서, PageEntity에 대한 추가적인 캐싱이 불필요해보여요
                    // https://firebase.google.com/docs/firestore/manage-data/enable-offline
                    self.savePageToCache(pages: pages)
                        .sink(receiveCompletion: { completion in
                            guard case .failure(let error) = completion else { return }
                            promise(.failure(error))
                        }, receiveValue: { _ in
                            promise(.success(pages))
                        })
                        .store(in: &self.cancellables)
                }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    func deletePages(for pair: DDID) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return promise(.failure(PageRepositoryError.failedToDeletePage)) }
            
            Publishers.Zip(
                self.firebaseNetworkService.deleteDocuments(collection: .page, fieldPath: .documentID(), prefix: pair.ddidString),
                self.firebaseNetworkService.deleteStorageFolder(path: pair.ddidString)
            )
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                promise(.failure(error))
            } receiveValue: { _ in
                promise(.success(()))
            }
            .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    func deletePage(for page: PageEntity) -> AnyPublisher<Void, Error> {
        guard let pairId = page.author.pairId?.ddidString else {
            return Fail(error: PageRepositoryError.failedToDeletePage).eraseToAnyPublisher()
        }
        return self.firebaseNetworkService.deleteDocument(collection: .page, document: pairId + page.jsonPath)
    }
    
    private func savePageToCache(pages: [PageEntity]) -> AnyPublisher<Void, Error> {
        let savePublishers = pages.map { self.pageEntityPersistenceService.savePageEntity($0) }
        
        return Publishers.MergeMany(savePublishers)
            .collect()
            .map { _ -> Void in () }
            .eraseToAnyPublisher()
    }
}
