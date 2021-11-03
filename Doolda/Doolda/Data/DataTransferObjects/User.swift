//
//  User.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/03.
//

import Foundation

struct User: Codable {
    let pairId: String
    
    init?(data: [String: Any]) {
        if let key = data.keys.first,
           key == "pairId",
           let pairId = data[key] as? String {
            self.pairId = pairId
        } else {
            return nil
        }
    }
}
