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
    static let coreDataModelName = "CoreDataModel"
    
    static let shared = CoreDataPersistenceService()
    
    lazy var context: NSManagedObjectContext? = {
        guard self.isPersistentStoreLoaded else { return nil }
        let context = self.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    lazy var backgroundContext: NSManagedObjectContext? = {
        guard self.isPersistentStoreLoaded else { return nil }
        let context = self.persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    private var isPersistentStoreLoaded = false
    private var persistentContainer: NSPersistentContainer
    
    private init() {
        self.persistentContainer = NSPersistentContainer(name: Self.coreDataModelName)
        self.persistentContainer.loadPersistentStores { [weak self] _, error in
            guard error == nil else { return }
            self?.isPersistentStoreLoaded = true
        }
    }
}
