//
//  Document.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/06.
//

import Foundation

struct Document: Codable {
    let name: String
    let fields: [String: [String: String]]
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case fields = "fields"
    }
}
