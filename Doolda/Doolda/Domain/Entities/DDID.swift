//
//  DDID.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/05.
//

import Foundation

struct DDID: Equatable {
    let id: String
    
    init() {
        self.id = UUID().uuidString
    }
    
    init?(from dto: DDIDDataTransferObject) {
        guard let id = dto.id,
              Self.isValid(id: id) else { return nil }
        self.id = id
    }
    
    static func isValid(id: String) -> Bool {
        return id.range(of: "\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}", options: .regularExpression) != nil
    }
}
