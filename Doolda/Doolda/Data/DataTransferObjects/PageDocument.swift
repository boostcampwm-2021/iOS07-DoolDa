//
//  PageDocument.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/14.
//

import Foundation

struct PageDocument: Codable {
    var authorId: String? { return self.fields["author"]?["stringValue"] }
    var pairId: String? { return self.fields["pairId"]?["stringValue"] }
    var createdTime: String? { return self.fields["createdTime"]?["timestampValue"] }
    var updatedTime: String? { return self.fields["updatedTime"]?["timestampValue"] }
    var jsonPath: String? { return self.fields["jsonPath"]?["stringValue"] }
    let fields: [String: [String: String]]
    
    init(author: String, createdTime: Date, updatedTime: Date, jsonPath: String, pairId: String) {
        let formattedCreatedTimeString = DateFormatter.firestoreFormatter.string(from: createdTime)
        let formattedUpdatedTimeString = DateFormatter.firestoreFormatter.string(from: updatedTime)
        self.fields = [
            "author": [
                "stringValue": author
            ],
            "createdTime": [
                "timestampValue": formattedCreatedTimeString
            ],
            "updatedTime": [
                "timestampValue": formattedUpdatedTimeString
            ],
            "jsonPath": [
                "stringValue": jsonPath
            ],
            "pairId": [
                "stringValue": pairId
            ]
        ]
    }
    
    init?(document: [String: [String: String]]) {
        guard let author = document["author"]?["stringValue"],
              let createdTime = document["createdTime"]?["timestampValue"],
              let updatedTime = document["updatedTime"]?["timestampValue"],
              let jsonPath = document["jsonPath"]?["stringValue"],
              let pairId = document["pairId"]?["stringValue"] else { return nil }
        self.fields = [
            "author": [
                "stringValue": author
            ],
            "createdTime": [
                "timestampValue": createdTime
            ],
            "updatedTime": [
                "timestampValue": updatedTime
            ],
            "jsonPath": [
                "stringValue": jsonPath
            ],
            "pairId": [
                "stringValue": pairId
            ]
        ]
    }
    
    func toPageEntity() -> PageEntity? {
        guard let authorId = self.authorId,
              let pairId = self.pairId,
              let authorDDID = DDID(from: authorId),
              let pairDDID = DDID(from: pairId),
              let createdTimeString = self.createdTime,
              let formattedCreatedTime = DateFormatter.firestoreFormatter.date(from: createdTimeString),
              let updatedTimeString = self.updatedTime,
              let formattedUpdatedTime = DateFormatter.firestoreFormatter.date(from: updatedTimeString),
              let jsonPath = self.jsonPath else { return nil }
        return PageEntity(
            author: User(id: authorDDID, pairId: pairDDID),
            createdTime: formattedCreatedTime,
            updatedTime: formattedUpdatedTime,
            jsonPath: jsonPath
        )
    }
}
