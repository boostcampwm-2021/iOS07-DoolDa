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
    private let networkService: URLSessionNetworkServiceProtocol
    private let coreDataPageEntityPersistenceService: CoreDataPageEntityPersistenceServiceProtocol
    private let fileManagerPersistenceService: FileManagerPersistenceServiceProtocol
    private let encoder: JSONEncoder
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        networkService: URLSessionNetworkServiceProtocol,
        coreDataPageEntityPersistenceService: CoreDataPageEntityPersistenceServiceProtocol,
        fileManagerPersistenceService: FileManagerPersistenceServiceProtocol,
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.networkService = networkService
        self.coreDataPageEntityPersistenceService = coreDataPageEntityPersistenceService
        self.fileManagerPersistenceService = fileManagerPersistenceService
        self.encoder = encoder
    }
    
    func save(rawPage: RawPageEntity, at folder: String, with name: String) -> AnyPublisher<RawPageEntity, Error> {
        do {
            let data = try self.encoder.encode(rawPage)
            let request = FirebaseAPIs.uploadDataFile(folder, name, data)
            let publisher: AnyPublisher<[String:String], Error> = self.networkService.request(request)
            
            return publisher
                .map { _ in rawPage }
                .eraseToAnyPublisher()
        } catch(let error) {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func fetch(at folder: String, with name: String) -> AnyPublisher<RawPageEntity, Error> {
        let fileName = "\(folder)\(name)"
        
        if self.fileManagerPersistenceService.isFileExists(at: .cache, fileName: fileName) {
            return self.fileManagerPersistenceService.fetch(at: .cache, fileName: fileName)
                       .decode(type: RawPageEntity.self, decoder: JSONDecoder())
                       .eraseToAnyPublisher()
        } else {
            return self.fetchRawPageEntityFromServer(at: folder, with: name)
                .map { [weak self] rawPageEntity in
                    self?.saveRawPageEntityToCache(rawPageEntity: rawPageEntity, fileName: fileName)
                    return rawPageEntity
                }
                .eraseToAnyPublisher()
        }
    }
    
    private func fetchRawPageEntityFromServer(at folder: String, with name: String) -> AnyPublisher<RawPageEntity, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return promise(.failure(RawPageRepositoryError.failedToFetchRawPage)) }
            
            let request = FirebaseAPIs.downloadDataFile(folder, name)
            let publisher: AnyPublisher<RawPageEntity, Error> = self.networkService.request(request)
            publisher.sink { completion in
                guard case .failure(let error) = completion else { return }
                promise(.failure(error))
            } receiveValue: { rawPageEntity in
                promise(.success(rawPageEntity))
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
}
