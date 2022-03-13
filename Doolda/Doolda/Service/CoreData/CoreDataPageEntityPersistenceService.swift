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

final class CoreDataPageEntityPersistenceService: CoreDataPageEntityPersistenceServiceProtocol {
    
    private let coreDataPersistenceService: CoreDataPersistenceServiceProtocol
    
    init(coreDataPersistenceService: CoreDataPersistenceServiceProtocol) {
        self.coreDataPersistenceService = coreDataPersistenceService
    }
    
    func isPageEntityUpToDate(_ pageEntity: PageEntity) -> AnyPublisher<Bool, Error> {
        guard let context = coreDataPersistenceService.backgroundContext else {
            return Fail(error: CoreDataPageEntityPersistenceServiceError.failedToInitializeCoreDataContainer).eraseToAnyPublisher()
        }
        
        return Future { promise in
            context.perform {
                let fetchRequest = CoreDataPageEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(
                    format: "%K == %@",
                    #keyPath(CoreDataPageEntity.jsonPath),
                    pageEntity.jsonPath
                )
                
                do {
                    guard let fetchResult = try context.fetch(fetchRequest).first else { return promise(.success(false)) }
                    return promise(.success(fetchResult.isUpToDate))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchPageEntities() -> AnyPublisher<[PageEntity], Error> {
        guard let context = coreDataPersistenceService.backgroundContext else {
            return Fail(error: CoreDataPageEntityPersistenceServiceError.failedToInitializeCoreDataContainer).eraseToAnyPublisher()
        }
        
        return Future { promise in
            context.perform {
                let fetchRequest = CoreDataPageEntity.fetchRequest()
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdTime", ascending: false)]
                
                do {
                    let fetchResult = try context.fetch(fetchRequest)
                    promise(.success(fetchResult.compactMap { $0.toPageEntity() }))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func savePageEntity(_ pageEntity: PageEntity) -> AnyPublisher<PageEntity, Error> {
        guard let context = coreDataPersistenceService.backgroundContext,
              let coreDataPageEntity = NSEntityDescription.entity(forEntityName: CoreDataPageEntity.coreDataPageEntityName, in: context) else {
            return Fail(error: CoreDataPageEntityPersistenceServiceError.failedToInitializeCoreDataContainer).eraseToAnyPublisher()
        }
        
        return Future { promise in
            context.perform {
                let fetchRequest = CoreDataPageEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(
                    format: "%K == %@",
                    #keyPath(CoreDataPageEntity.jsonPath),
                    pageEntity.jsonPath
                )
                
                do {
                    let fetchResults = try context.fetch(fetchRequest)
                    
                    if let fetchResult = fetchResults.first {
                        switch fetchResult.updatedTime {
                        case .some(let updatedTime): fetchResult.update(pageEntity, isUpToDate: updatedTime == pageEntity.updatedTime)
                        case .none: fetchResult.update(pageEntity)
                        }
                    } else if let coreDataPage = NSManagedObject(entity: coreDataPageEntity, insertInto: context) as? CoreDataPageEntity {
                        coreDataPage.update(pageEntity)
                    }
                    
                    if context.hasChanges { try context.save() }
                    promise(.success(pageEntity))
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
