//
//  FirebaseMessageUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Combine
import Foundation

protocol FirebaseMessageUseCaseProtocol {
    var errorPublisher: Published<Error?>.Publisher { get }
    
    func sendMessage(to user: DDID, message: PushMessageEntity)
}
