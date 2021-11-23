//
//  PushMessageEntity.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/23.
//

import Foundation

struct PushMessageEntity {
    let title: String
    let body: String
    let data: [String: String]
    
    static let userPairedWithFriend: PushMessageEntity = PushMessageEntity(
        title: "안녕?! 🙋‍♀️🙋‍♂️",
        body: "누군가가 당신을 친구로 연결했어요!",
        data: [:]
    )
    
    static let userPostedNewPage: PushMessageEntity = PushMessageEntity(
        title: "띵동! 🔔",
        body: "친구가 다이어리를 작성했어요!",
        data: [:]
    )
    
    static let userRequestedNewPage: PushMessageEntity = PushMessageEntity(
        title: "쿡 쿡! 🥺👉🏻👉🏻",
        body: "친구가 다이어리를 기다리고있어요.\n새 다이어리를 작성해주세요!",
        data: [:]
    )
}
