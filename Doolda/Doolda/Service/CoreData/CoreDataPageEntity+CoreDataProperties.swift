//
//  CoreDataPageEntity+CoreDataProperties.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/16.
//
//

import Foundation
import CoreData


extension CoreDataPageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataPageEntity> {
        return NSFetchRequest<CoreDataPageEntity>(entityName: "CoreDataPageEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var pairId: String?
    @NSManaged public var jsonPath: String?
    @NSManaged public var timeStamp: Date?

}

extension CoreDataPageEntity : Identifiable {

}
