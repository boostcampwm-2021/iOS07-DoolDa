//
//  UserDocument.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/03.
//

import Foundation

struct UserDocument: Codable {
    var uid: String? {
        return name.components(separatedBy: "/").last
    }
    var userId: String? {
        return self.fields["id"]?["stringValue"]
    }
    var pairId: String? {
        return self.fields["pairId"]?["stringValue"]
    }
    var friendId: String? {
        return self.fields["friendId"]?["stringValue"]
    }
    
    let name: String
    let fields: [String: [String: String]]
    
    init(uid: String, userId: String, pairId: String, friendId: String) {
        self.name = uid
        self.fields = [
            "id": [
                "stringValue": userId
            ],
            "pairId": [
                "stringValue": pairId
            ],
            "friendId": [
                "stringValue": friendId
            ]
        ]
    }
    
    func toUser() -> User? {
        guard let userIdString = self.userId,
              let userDDID = DDID(from: userIdString),
              let pairIdString = self.pairId,
              let friendIdString = self.friendId else { return nil }
        return User(id: userDDID, pairId: DDID(from: pairIdString), friendId: DDID(from: friendIdString))
    }
}
