//
//  FCMTokenDocument.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/23.
//

import Foundation

struct FCMTokenDocument: Codable {
    var token: String? { return self.fields["token"]?["stringValue"] }
    let fields: [String: [String: String]]
    
    init(token: String) {
        self.fields = [
            "token": [
                "stringValue": token
            ]
        ]
    }
    
    init?(document: [String: [String: String]]) {
        guard let token = document["token"]?["stringValue"] else { return nil }
        self.fields = [
            "token": [
                "stringValue": token
            ]
        ]
    }
}
