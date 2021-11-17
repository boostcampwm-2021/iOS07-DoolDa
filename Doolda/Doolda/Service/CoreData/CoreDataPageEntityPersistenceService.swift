//
//  CoreDataPageEntityPersistenceService.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/17.
//

import Combine
import CoreData
import Foundation

enum CoreDataPageEntityPersistenceServiceError: LocalizedError {
    case failedToInitializeCoreDataContainer
    
    var errorDescription: String? {
        switch self {
        case .failedToInitializeCoreDataContainer:
            return "CoreDataContainer 초기화에 실패했습니다."
        }
    }
}

class CoreDataPageEntityPersistenceService: CoreDataPageEntityPersistenceServiceProtocol {
    private let coreDataPersistenceService: CoreDataPersistenceServiceProtocol
    
    init(coreDataPersistenceService: CoreDataPersistenceServiceProtocol) {
        self.coreDataPersistenceService = coreDataPersistenceService
    }
    
    func fetchPageEntities() -> AnyPublisher<[PageEntity], Error> {
        guard let context = coreDataPersistenceService.context else {
            return Fail(error: CoreDataPageEntityPersistenceServiceError.failedToInitializeCoreDataContainer).eraseToAnyPublisher()
        }

        do {
            let fetchRequest = CoreDataPageEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
            let fetchResult = try context.fetch(fetchRequest)
            let pageEntities = fetchResult.compactMap { $0.toPageEntity() }
            
            return Just(pageEntities).setFailureType(to: Error.self).eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func savePageEntity(_ pageEntity: PageEntity) -> AnyPublisher<PageEntity, Error> {
        guard let context = coreDataPersistenceService.context else {
            return Fail(error: CoreDataPageEntityPersistenceServiceError.failedToInitializeCoreDataContainer).eraseToAnyPublisher()
        }
        
        let entity = CoreDataPageEntity(context: context)
        entity.update(pageEntity)
        
        do {
            try context.save()
            return Just(pageEntity).setFailureType(to: Error.self).eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func removeAllPageEntity() -> AnyPublisher<Void, Error> {
        guard let context = coreDataPersistenceService.context else {
            return Fail(error: CoreDataPageEntityPersistenceServiceError.failedToInitializeCoreDataContainer).eraseToAnyPublisher()
        }
        
        do {
            let fetchRequest = CoreDataPageEntity.fetchRequest()
            let fetchResult = try context.fetch(fetchRequest)
            
            fetchResult.forEach { context.delete($0) }
            try context.save()
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
