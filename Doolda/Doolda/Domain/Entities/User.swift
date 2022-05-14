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
    var isAgreed: Bool = false
    
    var dictionary: [String : Any] {
        return [
            "pairId": self.pairId?.ddidString ?? "",
            "friendId": self.friendId?.ddidString ?? "",
            "isAgreed": self.isAgreed
        ]
    }
    
    init(
        id: DDID,
        pairId: DDID? = nil,
        friendId: DDID? = nil,
        isAgreed: Bool = false
    ) {
        self.id = id
        self.pairId = pairId
        self.friendId = friendId
        self.isAgreed = isAgreed
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(pairId)
        hasher.combine(friendId)
        hasher.combine(isAgreed)
    }
    
    func agreed() -> User {
        User(id: id, pairId: pairId, friendId: friendId, isAgreed: true)
    }
}
