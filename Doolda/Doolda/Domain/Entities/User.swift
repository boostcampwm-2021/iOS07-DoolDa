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
    var isPaired: Bool {
        guard let pairId = pairId, let friendId = friendId else { return false }
        return !pairId.ddidString.isEmpty && !friendId.ddidString.isEmpty
    }
    
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
    
    func agreedUser() -> User {
        User(id: id, pairId: pairId, friendId: friendId, isAgreed: true)
    }
    
    func soloUser() -> User {
        User(id: id, pairId: id, friendId: id, isAgreed: isAgreed)
    }
    
    func pairedUser(with other: User, as pair: DDID) -> User {
        User(id: id, pairId: pair, friendId: other.id, isAgreed: isAgreed)
    }
}
