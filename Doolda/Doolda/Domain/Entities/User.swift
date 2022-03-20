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
    
    var dictionary: [String : Any] {
        return [
            "pairId": self.pairId?.ddidString ?? "",
            "friendId": self.friendId?.ddidString ?? ""
        ]
    }
    
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
