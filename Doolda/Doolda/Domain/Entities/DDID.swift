//
//  DDID.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/05.
//

import Foundation

struct DDID: Equatable {
    let ddidString: String
    
    init() {
        self.ddidString = UUID().uuidString
    }
    
    init?(from dto: DDIDDataTransferObject) {
        guard let id = dto.id,
              Self.isValid(ddidString: id) else { return nil }
        self.ddidString = id
    }
    
    init?(from string: String) {
        if Self.isValid(id: string) {
            self.id = string
        } else {
            return nil
        }
    }
    
    static func isValid(id: String) -> Bool {
        return id.range(of: "\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}", options: .regularExpression) != nil
    }
}
