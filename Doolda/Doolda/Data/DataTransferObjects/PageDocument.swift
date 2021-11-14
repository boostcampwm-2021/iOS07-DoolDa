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
    var timeStamp: String? { return self.fields["createdTime"]?["timestampValue"] }
    var jsonPath: String? { return self.fields["jsonPath"]?["stringValue"] }
    let fields: [String: [String: String]]
    
    init(author: String, createdTime: Date, jsonPath: String, pairId: String) {
        let formattedString = DateFormatter.firestoreFormatter.string(from: createdTime)
        self.fields = [
            "author": [
                "stringValue": author
            ],
            "createdTime": [
                "timestampValue": formattedString
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
              let timeStamp = self.timeStamp,
              let formattedDate = DateFormatter.firestoreFormatter.date(from: timeStamp),
              let jsonPath = self.jsonPath else { return nil }
        return PageEntity(author: User(id: authorDDID, pairId: pairDDID), timeStamp: formattedDate, jsonPath: jsonPath)
    }
}

struct QueryDocument: Codable {
    let document: [String: [String: [String: String]]]
}
