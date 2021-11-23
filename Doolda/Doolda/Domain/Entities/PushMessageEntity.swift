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
        title: "똑똑! 🙋‍♀️🙋‍♂️",
        body: "누군가가 당신을 친구로 연결했어요!",
        data: [:]
    )
    
    // 이거 탭하는 경우엔 새로고쳐야할듯. 새로고침이 성공할 때에는 안보내야함.
    static let userPostedNewPage: PushMessageEntity = PushMessageEntity(
        title: "띵동! 🔔",
        body: "친구가 다이어리를 작성했어요!\n새 다이어리를 확인해볼까요?",
        data: [:]
    )
    
    static let userRequestedNewPage: PushMessageEntity = PushMessageEntity(
        title: "쿡쿡! 🥺👉🏻👉🏻",
        body: "친구가 다이어리 작성을 기다리고있어요.\n새 다이어리를 작성해볼까요?",
        data: [:]
    )
}
