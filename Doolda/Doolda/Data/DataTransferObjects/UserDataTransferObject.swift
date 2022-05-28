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
    var isAgreed: Bool?
    
    func toUser(id: DDID) -> User {
        return User(
            id: id,
            pairId: DDID(from: self.pairId ?? ""),
            friendId: DDID(from: self.friendId ?? ""),
            isAgreed: self.isAgreed ?? false
        )
    }
}

extension UserDataTransferObject: DataTransferable {
    init?(dictionary: [String : Any]) {
        guard let pairId = dictionary["pairId"] as? String,
              let friendId = dictionary["friendId"] as? String,
              let isAgreed = dictionary["isAgreed"] as? Bool else { return nil }
        self.pairId = pairId
        self.friendId = friendId
        self.isAgreed = isAgreed
    }
    
    var dictionary: [String : Any] {
        return [
            "pairId": self.pairId ?? "",
            "friendId": self.friendId ?? "",
            "isAgreed": self.isAgreed ?? false
        ]
    }
}
