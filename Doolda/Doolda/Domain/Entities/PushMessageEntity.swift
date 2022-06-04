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
    
    init(title: String, body: String, data: [String: String] = [:]) {
        self.title = title
        self.body = body
        self.data = data
    }
    
    static let userPairedWithFriend: PushMessageEntity = PushMessageEntity(
        title: "똑똑! 🙋‍♀️🙋‍♂️",
        body: "누군가가 당신을 친구로 연결했어요!"
    )
    
    static let userPostedNewPage: PushMessageEntity = PushMessageEntity(
        title: "띵동! 🔔",
        body: "친구가 다이어리를 작성했어요!\n새 다이어리를 확인해볼까요?",
        data: [DataKey.event: DataValue.userPostedNewPage]
    )
    
    static let userRequestedNewPage: PushMessageEntity = PushMessageEntity(
        title: "쿡쿡! 🥺👉🏻👉🏻",
        body: "친구가 다이어리 작성을 기다리고있어요.\n새 다이어리를 작성해볼까요?",
        data: [DataKey.event: DataValue.userRequestedNewPage]
    )
    
    static let userDisconnected: PushMessageEntity = PushMessageEntity(
        title: "연결 해제",
        body: "상대방이 연결을 해제했습니다."
    )
    
    enum DataKey {
        static let event = "event"
    }
    
    enum DataValue {
        static let userPostedNewPage = "userPostedNewPage"
        static let userRequestedNewPage = "userRequestedNewPage"
    }
    
    enum Notifications {
        static let dict: [String: Notification.Name] = [
            DataValue.userPostedNewPage: didReceiveUserPostedNewPageEvent,
            DataValue.userRequestedNewPage: didReceiveUserRequestedNewPageEvent
        ]
        
        static let didReceiveUserPostedNewPageEvent = Notification.Name(rawValue: "didReceiveUserPostedNewPageEvent")
        static let didReceiveUserRequestedNewPageEvent = Notification.Name(rawValue: "didReceiveUserRequestedNewPageEvent")
    }
}
