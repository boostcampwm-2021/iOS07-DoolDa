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
        let isFileExists = self.fileManagerPersistenceService.isFileExists(at: .cache, fileName: "\(folder)\(name)")
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            self.coreDataPageEntityPersistenceService.isPageEntityUpToDate(metaData)
                .sink { completion in
                    guard case .failure(let error) = completion else { return }
                    return promise(.failure(error))
                } receiveValue: { isUpToDate in
                    let rawPageEntityPublisher = isUpToDate && isFileExists
                    ? self.fetchRawPageEntityFromCache(fileName: "\(folder)\(name)")
                    : self.fetchRawPageEntityFromServer(at: folder, with: name)
                    
                    rawPageEntityPublisher
                        .sink { completion in
                            guard case .failure(let error) = completion else { return }
                            return promise(.failure(error))
                        } receiveValue: { [weak self] entity in
                            self?.setIsUpToDateFlag(medaData: metaData)
                            return promise(.success(entity))
                        }
                        .store(in: &self.cancellables)
                }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    private func fetchRawPageEntityFromServer(at folder: String, with name: String) -> AnyPublisher<RawPageEntity, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            self.networkService.donwloadData(path: folder, fileName: name)
                .sink { completion in
                    guard case .failure(let error) = completion else { return }
                    return promise(.failure(error))
                } receiveValue: { [weak self] data in
                    guard let self = self else { return }
                    self.fileManagerPersistenceService.save(data: data, at: .cache, fileName: "\(folder)\(name)")
                        .sink { _ in } receiveValue: { _ in }
                        .store(in: &self.cancellables)
                    do {
                        let entity = try self.decoder.decode(RawPageEntity.self, from: data)
                        return promise(.success(entity))
                    } catch {
                        return promise(.failure(error))
                    }
                }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    private func fetchRawPageEntityFromCache(fileName: String) -> AnyPublisher<RawPageEntity, Error> {
        return self.fileManagerPersistenceService.fetch(at: .cache, fileName: fileName)
            .decode(type: RawPageEntity.self, decoder: self.decoder)
            .eraseToAnyPublisher()
    }
    
    private func setIsUpToDateFlag(medaData: PageEntity) {
        self.coreDataPageEntityPersistenceService.savePageEntity(medaData)
            .sink { _ in } receiveValue: { _ in }
            .store(in: &self.cancellables)
    }
}
