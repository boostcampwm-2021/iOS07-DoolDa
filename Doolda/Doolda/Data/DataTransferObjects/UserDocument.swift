//
//  UserDocument.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/03.
//

import Foundation

struct UserDocument: Codable {
    var userId: String? {
        return name.components(separatedBy: "/").last
    }
    var pairId: String? {
        return self.fields["pairId"]?["stringValue"]
    }
    
    let name: String
    let fields: [String: [String: String]]
    
    init(userId: String, pairId: String) {
        self.name = userId
        self.fields = [
            "pairId": [
                "stringValue": pairId
            ]
        ]
    }
    
    func toUser() -> User? {
        guard let userIdString = self.userId,
              let userDDID = DDID(from: userIdString),
              let pairIdString = self.pairId else { return nil }
        return User(id: userDDID, pairId: DDID(from: pairIdString))
    }
}
