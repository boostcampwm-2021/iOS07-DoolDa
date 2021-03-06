//
//  PairDocument.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/03.
//

import Foundation

struct PairDocument: Codable {
    let name: String
    let fields: [String: [String: String]]
    
    var pairId: String? {
        return name.components(separatedBy: "/").last
    }
    var recentlyEditedUser: String? {
        return self.fields["recentlyEditedUser"]?["stringValue"]
    }
    
    init(pairId: String, recentlyEditedUser: String) {
        self.name = pairId
        self.fields = [
            "recentlyEditedUser": [
                "stringValue": recentlyEditedUser
            ]
        ]
    }
}
