//
//  UserDocument.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/03.
//

import Foundation

struct UserDocument {
    let fields: [String: Any]
    
    init(pairId: String) {
        self.fields = [
            "pairId": [
                "stringValue": pairId
            ]
        ]
    }
}
