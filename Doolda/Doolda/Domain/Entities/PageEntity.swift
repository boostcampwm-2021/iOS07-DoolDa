//
//  PageEntity.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/04.
//

import Foundation

import Firebase

struct PageEntity: Hashable {
    let author: User
    let createdTime: Date
    let updatedTime: Date
    let jsonPath: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(author)
        hasher.combine(createdTime)
        hasher.combine(updatedTime)
        hasher.combine(jsonPath)
    }
}

extension PageEntity: DataTransferable {
    init?(dictionary: [String : Any]) {
        guard let authorId = dictionary["author"] as? String,
              let pairId = dictionary["pairId"] as? String,
              let authorDDID = DDID(from: authorId),
              let pairDDID = DDID(from: pairId),
              let createdTime = dictionary["createdTime"] as? Timestamp,
              let updatedTime = dictionary["updatedTime"] as? Timestamp,
              let jsonPath = dictionary["jsonPath"] as? String else { return nil }
        
        self.author = User(id: authorDDID, pairId: pairDDID)
        self.createdTime = createdTime.dateValue()
        self.updatedTime = updatedTime.dateValue()
        self.jsonPath = jsonPath
    }
    
    var dictionary: [String : Any] {
        return [
            "author": self.author.id.ddidString,
            "createdTime": self.createdTime,
            "updatedTime": self.updatedTime,
            "jsonPath": self.jsonPath,
            "pairId": self.author.pairId?.ddidString ?? ""
        ]
    }
}
