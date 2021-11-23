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
        guard let context = coreDataPersistenceService.backgroundContext else {
            return Fail(error: CoreDataPageEntityPersistenceServiceError.failedToInitializeCoreDataContainer).eraseToAnyPublisher()
        }
        
        return Future { promise in
            context.perform {
                do {
                    let fetchRequest = CoreDataPageEntity.fetchRequest()
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdTime", ascending: false)]
                    let fetchResult = try context.fetch(fetchRequest)
                    let pageEntities = fetchResult.compactMap { $0.toPageEntity() }
                    
                    promise(.success(pageEntities))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func savePageEntity(_ pageEntity: PageEntity) -> AnyPublisher<Void, Error> {
        guard let context = coreDataPersistenceService.backgroundContext,
              let coreDataPageEntity = NSEntityDescription.entity(forEntityName: CoreDataPageEntity.coreDataPageEntityName, in: context) else {
            return Fail(error: CoreDataPageEntityPersistenceServiceError.failedToInitializeCoreDataContainer).eraseToAnyPublisher()
        }
        
        return Future { promise in
            context.perform {
                if let managedObject = NSManagedObject(entity: coreDataPageEntity, insertInto: context) as? CoreDataPageEntity {
                    managedObject.update(pageEntity)
                }
                
                do {
                    try context.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func removeAllPageEntity() -> AnyPublisher<Void, Error> {
        guard let context = coreDataPersistenceService.backgroundContext else {
            return Fail(error: CoreDataPageEntityPersistenceServiceError.failedToInitializeCoreDataContainer).eraseToAnyPublisher()
        }
        
        return Future { promise in
            context.perform {
                do {
                    let fetchRequest = CoreDataPageEntity.fetchRequest()
                    let fetchResult = try context.fetch(fetchRequest)
                    
                    fetchResult.forEach { context.delete($0) }
                    try context.save()
                    return promise(.success(()))
                } catch {
                    return promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
