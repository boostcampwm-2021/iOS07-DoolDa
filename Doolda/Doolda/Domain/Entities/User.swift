//
//  User.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/05.
//

import Foundation

struct User: Hashable {
    let id: DDID
    var pairId: DDID?
    var friendId: DDID?
    
    init(id: DDID, pairId: DDID? = nil, friendId: DDID? = nil) {
        self.id = id
        self.pairId = pairId
        self.friendId = friendId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(pairId)
        hasher.combine(friendId)
    }
}

extension User: DataTransferable {
    init?(dictionary: [String : Any]) {
        guard let id = dictionary["id"] as? String,
              let pairId = dictionary["pairId"] as? String,
              let friendId = dictionary["friendId"] as? String,
              let ddid = DDID(from: id),
              let pairDDID = DDID(from: pairId),
              let friendDDID = DDID(from: friendId) else { return nil }
        
        self.id = ddid
        self.pairId = pairDDID
        self.friendId = friendDDID
    }
    
    var dictionary: [String : Any] {
        return [
            "id": self.id.ddidString,
            "pairId": self.pairId?.ddidString ?? "",
            "friendId": self.friendId?.ddidString ?? ""
        ]
    }
}
