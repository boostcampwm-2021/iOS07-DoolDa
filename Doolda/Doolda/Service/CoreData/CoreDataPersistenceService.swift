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
    private var isPersistentStoreLoaded = false
    
    lazy private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores { _, error in
            guard error == nil else { return }
            self.isPersistentStoreLoaded = true
        }
        return container
    }()
    
    var context: NSManagedObjectContext? {
        guard self.isPersistentStoreLoaded else { return nil }
        return self.persistentContainer.viewContext
    }
}
