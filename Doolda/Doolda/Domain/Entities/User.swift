//
//  User.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/05.
//

import Foundation

struct User: Equatable {
    let id: DDID
    var pairId: DDID?
    
    init(id: DDID, pairId: DDID? = nil) {
        self.id = id
        self.pairId = pairId
    }
}
