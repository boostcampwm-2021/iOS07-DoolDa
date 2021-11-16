//
//  CoreDataPersistenceService.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/16.
//

import Combine
import CoreData
import Foundation

enum CoreDataPersistenceServiceError: LocalizedError {
    case failedToloadPersistentStores
    case failedToSaveEntity
    
    var errorDescription: String? {
        switch self {
        case .failedToloadPersistentStores:
            return "PersistentStore를 로드하는데 실패했습니다."
        case .failedToSaveEntity:
            return "Entity 저장에 실패했습니다."
        }
    }
}

final class CoreDataPersistenceService: CoreDataPersistenceServiceProtocol {
    static let shared = CoreDataPersistenceService()
    
    fileprivate var persistentContainer: NSPersistentContainer
    
    private var isPersistentStoresLoaded: Bool = true
    
    private init() {
        self.persistentContainer = NSPersistentContainer(name: "CoreDataModel")
        self.persistentContainer.loadPersistentStores { _, error in
            if error != nil {
                self.isPersistentStoresLoaded = false
            }
        }
    }
    
    func save() -> AnyPublisher<Void, Error> {
        guard self.isPersistentStoresLoaded else {
            return Fail(error: CoreDataPersistenceServiceError.failedToloadPersistentStores).eraseToAnyPublisher()
        }
        
        let context = self.persistentContainer.viewContext

        do {
            try context.save()
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> AnyPublisher<[T], Error> {
        guard self.isPersistentStoresLoaded else {
            return Fail(error: CoreDataPersistenceServiceError.failedToloadPersistentStores).eraseToAnyPublisher()
        }
        
        let context = self.persistentContainer.viewContext

        do {
            let fetchResult = try context.fetch(request)
            return Just(fetchResult).setFailureType(to: Error.self).eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func delete(objects: [NSManagedObject]) -> AnyPublisher<Void, Error> {
        guard self.isPersistentStoresLoaded else {
            return Fail(error: CoreDataPersistenceServiceError.failedToloadPersistentStores).eraseToAnyPublisher()
        }
        
        let context = self.persistentContainer.viewContext

        objects.forEach { context.delete($0) }
        return self.save()
    }
    
    fileprivate func entityDescription(name: String) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: name, in: self.persistentContainer.viewContext)
    }
}
