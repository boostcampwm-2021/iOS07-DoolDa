//
//  UserDataTransferObject.swift
//  Doolda
//
//  Created by 김민주 on 2022/03/20.
//

import Foundation

struct UserDataTransferObject {
    var pairId: String?
    var friendId: String?
    
    func toUser(id: DDID) -> User {
        return User(id: id, pairId: DDID(from: self.pairId ?? ""), friendId: DDID(from: self.friendId ?? ""))
    }
}

extension UserDataTransferObject: DataTransferable {
    init?(dictionary: [String : Any]) {
        guard let pairId = dictionary["pairId"] as? String,
              let friendId = dictionary["friendId"] as? String else { return nil }
        self.pairId = pairId
        self.friendId = friendId
    }
    
    var dictionary: [String : Any] {
        return [
            "pairId": self.pairId ?? "",
            "friendId": self.friendId ?? ""
        ]
    }
}
