//
//  CoreDataPersistenceServiceProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/16.
//

import CoreData
import Foundation

protocol CoreDataPersistenceServiceProtocol {
    var context: NSManagedObjectContext? { get }
    var backgroundContext: NSManagedObjectContext? { get }
}
