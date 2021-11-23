//
//  PageEntity.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/04.
//

import Foundation

struct PageEntity: Hashable {
    let author: User
    let createdTime: Date
    let updatedTime: Date
    let jsonPath: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(author)
        hasher.combine(createdTime)
        hasher.combine(updatedTime)
        hasher.combine(jsonPath)
    }
}
