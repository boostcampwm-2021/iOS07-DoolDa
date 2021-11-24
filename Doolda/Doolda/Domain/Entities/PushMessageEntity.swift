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
        data: ["notification": "userPairedWithFriend"]
    )
    
    static let userPostedNewPage: PushMessageEntity = PushMessageEntity(
        title: "띵동! 🔔",
        body: "친구가 다이어리를 작성했어요!\n새 다이어리를 확인해볼까요?",
        data: ["notification": "userRequestedNewPage"]
    )
    
    static let userRequestedNewPage: PushMessageEntity = PushMessageEntity(
        title: "쿡쿡! 🥺👉🏻👉🏻",
        body: "친구가 다이어리 작성을 기다리고있어요.\n새 다이어리를 작성해볼까요?",
        data: ["notification": "userRequestedNewPage"]
    )
    
    enum Notifications {
        static let userPairedWithFriend = Notification.Name("userPairedWithFriend")
        static let userPostedNewPage = Notification.Name("userPostedNewPage")
        static let userRequestedNewPage = Notification.Name("userRequestedNewPage")
    }
}
