//
//  PageEntity.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/04.
//

import Foundation

struct PageEntity: Hashable {
    let author: User
    let timeStamp: Date
    let jsonPath: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(author)
        hasher.combine(timeStamp)
        hasher.combine(jsonPath)
    }
}
