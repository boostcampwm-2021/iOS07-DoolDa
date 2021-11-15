//
//  DDID.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/05.
//

import Foundation

struct DDID: Hashable {
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
        if Self.isValid(ddidString: string) {
            self.ddidString = string
        } else {
            return nil
        }
    }
    
    static func isValid(ddidString: String) -> Bool {
        return ddidString.range(of: "\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}", options: .regularExpression) != nil
    }
}
