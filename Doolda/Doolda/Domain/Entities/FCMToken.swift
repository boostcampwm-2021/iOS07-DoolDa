//
//  FCMToken.swift
//  Doolda
//
//  Created by Seunghun Yang on 2022/03/20.
//

import Foundation

struct FCMToken: DataTransferable {
    let token: String
    
    init(token: String) {
        self.token = token
    }
    
    init?(dictionary: [String : Any]) {
        guard let token = dictionary["token"] as? String else { return nil }
        self.token = token
    }
    
    var dictionary: [String : Any] {
        ["token": token]
    }
}
