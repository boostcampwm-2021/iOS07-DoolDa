//
//  PairDocument.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/03.
//

import Foundation

struct PairDocument: Codable {
    let recentlyEditedUser: String
    
    init?(data: [String: Any]) {
        if let key = data.keys.first,
           key == "recentlyEditedUser",
           let recentlyEditedUser = data[key] as? String {
            self.recentlyEditedUser = recentlyEditedUser
        } else {
            return nil
        }
    }
}
