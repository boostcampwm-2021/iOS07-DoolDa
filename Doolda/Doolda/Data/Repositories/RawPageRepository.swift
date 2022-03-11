//
//  RawPageRepository.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/11.
//

import Combine
import Foundation
import OSLog

enum RawPageRepositoryError: LocalizedError {
    case failedToFetchRawPage
    
    var errorDescription: String? {
        switch self {
        case .failedToFetchRawPage:
            return "RawPage 패치에 실패했습니다."
        }
    }
}

class RawPageRepository: RawPageRepositoryProtocol {
    private let networkService: FirebaseNetworkServiceProtocol
    private let coreDataPageEntityPersistenceService: CoreDataPageEntityPersistenceServiceProtocol
    private let fileManagerPersistenceService: FileManagerPersistenceServiceProtocol
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        networkService: FirebaseNetworkServiceProtocol,
        coreDataPageEntityPersistenceService: CoreDataPageEntityPersistenceServiceProtocol,
        fileManagerPersistenceService: FileManagerPersistenceServiceProtocol,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.networkService = networkService
        self.coreDataPageEntityPersistenceService = coreDataPageEntityPersistenceService
        self.fileManagerPersistenceService = fileManagerPersistenceService
        self.encoder = encoder
        self.decoder = decoder
    }
    
    func save(rawPage: RawPageEntity, at folder: String, with name: String) -> AnyPublisher<RawPageEntity, Error> {
        return Future<RawPageEntity, Error> { [weak self] promise in
            do {
                guard let self = self else { return }
                let data = try self.encoder.encode(rawPage)
        
                self.networkService.uploadData(path: folder, fileName: name, data: data)
                    .sink { completion in
                        guard case .failure(let error) = completion else { return }
                        return promise(.failure(error))
                    } receiveValue: { _ in
                        return promise(.success(rawPage))
                    }
                    .store(in: &self.cancellables)
            } catch {
                return promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetch(metaData: PageEntity) -> AnyPublisher<RawPageEntity, Error> {
        guard let folder = metaData.author.pairId?.ddidString else {
            return Fail(error: RawPageRepositoryError.failedToFetchRawPage).eraseToAnyPublisher()
        }
        let name = metaData.jsonPath
        let fileName = "\(folder)\(name)"
        
        return Future { [weak self] promise in
            guard let self = self else {
                return promise(.failure(RawPageRepositoryError.failedToFetchRawPage))
            }
            
            self.coreDataPageEntityPersistenceService.isPageEntityUpToDate(metaData)
                .sink { completion in
                    guard case .failure(let error) = completion else { return }
                    promise(.failure(error))
                } receiveValue: { [weak self] isUpToDate in
                    guard let self = self else {
                        return promise(.failure(RawPageRepositoryError.failedToFetchRawPage))
                    }
                    
                    let fetchPublisher: AnyPublisher<RawPageEntity, Error>
                    
                    if self.fileManagerPersistenceService.isFileExists(at: .cache, fileName: fileName),
                       isUpToDate {
                        fetchPublisher = self.fileManagerPersistenceService.fetch(at: .cache, fileName: fileName)
                            .decode(type: RawPageEntity.self, decoder: JSONDecoder())
                            .eraseToAnyPublisher()
                    } else {
                        fetchPublisher = self.fetchRawPageEntityFromServer(at: folder, with: name)
                            .map { [weak self] rawPageEntity in
                                self?.saveRawPageEntityToCache(rawPageEntity: rawPageEntity, fileName: fileName)
                                return rawPageEntity
                            }
                            .eraseToAnyPublisher()
                    }
                    
                    fetchPublisher.sink { completion in
                        guard case .failure(let error) = completion else { return }
                        promise(.failure(error))
                    } receiveValue: { [weak self] rawPageEntity in
                        self?.setIsUpToDateFlag(medaData: metaData)
                        promise(.success(rawPageEntity))
                    }
                    .store(in: &self.cancellables)
                }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    private func fetchRawPageEntityFromServer(at folder: String, with name: String) -> AnyPublisher<RawPageEntity, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return promise(.failure(RawPageRepositoryError.failedToFetchRawPage)) }
            self.networkService.donwloadData(path: folder, fileName: name)
                .decode(type: RawPageEntity.self.self, decoder: self.decoder)
                .sink { completion in
                    guard case .failure(let error) = completion else { return }
                    return promise(.failure(error))
                } receiveValue: { entity in
                    return promise(.success(entity))
                }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    private func saveRawPageEntityToCache(rawPageEntity: RawPageEntity, fileName: String) {
        guard let data = try? JSONEncoder().encode(rawPageEntity) else {
            return os_log("RawPageEntity caching failure", type: .fault)
        }
        
        self.fileManagerPersistenceService.save(data: data, at: .cache, fileName: fileName)
            .sink { completion in
                guard case .failure = completion else { return }
                os_log("RawPageEntity caching failure", type: .fault)
            } receiveValue: { _ in }
            .store(in: &self.cancellables)
    }
    
    private func setIsUpToDateFlag(medaData: PageEntity) {
        self.coreDataPageEntityPersistenceService.savePageEntity(medaData)
            .sink { completion in
                guard case .failure = completion else { return }
                os_log("RawPageEntity caching failure", type: .fault)
            } receiveValue: { _ in }
            .store(in: &self.cancellables)
    }
}
