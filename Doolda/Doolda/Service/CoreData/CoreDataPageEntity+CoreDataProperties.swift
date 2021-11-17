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
        return NSFetchRequest<CoreDataPageEntity>(entityName: Self.coreDataPageEntityName)
    }

    @NSManaged public var id: String?
    @NSManaged public var pairId: String?
    @NSManaged public var jsonPath: String?
    @NSManaged public var timeStamp: Date?

    func toPageEntity() -> PageEntity? {
        guard let id = DDID(from: id ?? ""),
              let pairId = DDID(from: pairId ?? ""),
              let timeStamp = timeStamp,
              let jsonPath = jsonPath else { return nil }
        
        return PageEntity(author: User(id: id, pairId: pairId), timeStamp: timeStamp, jsonPath: jsonPath)
    }
    
    func update(_ pageEntity: PageEntity) {
        self.id = pageEntity.author.id.ddidString
        self.pairId = pageEntity.author.pairId?.ddidString
        self.jsonPath = pageEntity.jsonPath
        self.timeStamp = pageEntity.timeStamp
    }
}

extension CoreDataPageEntity : Identifiable {

}
