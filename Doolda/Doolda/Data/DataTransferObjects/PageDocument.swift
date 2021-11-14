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
    var timestamp: String? { return self.fields["createdTime"]?["timestampValue"] }
    var jsonPath: String? { return self.fields["jsonPath"]?["stringValue"] }
    let fields: [String: [String: String]]
    
    init(author: String, createdTime: Date, jsonPath: String, pairId: String) {
        self.fields = [
            "author": [
                "stringValue": author
            ],
            "createdTime": [
                "timestampValue": "2014-10-02T15:01:23Z"
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
              let jsonPath = document["jsonPath"]?["stringValue"],
              let pairId = document["pairId"]?["stringValue"] else { return nil }
        self.fields = [
            "author": [
                "stringValue": author
            ],
            "createdTime": [
                "timestampValue": createdTime
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
//              let date = Date(),
              let jsonPath = self.jsonPath else { return nil }
        return PageEntity(author: User(id: authorDDID, pairId: pairDDID), timeStamp: Date(), jsonPath: jsonPath)
    }
}

struct QueryDocument: Codable {
    let document: [String: [String: [String: String]]]
}
