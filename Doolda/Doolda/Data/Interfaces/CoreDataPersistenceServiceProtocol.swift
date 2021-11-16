//
//  CoreDataPersistenceServiceProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/16.
//

import Combine
import CoreData
import Foundation

protocol CoreDataPersistenceServiceProtocol {
    func save() -> AnyPublisher<Void, Error>
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> AnyPublisher<[T], Error>
    func delete(objects: [NSManagedObject]) -> AnyPublisher<Void, Error>
}
