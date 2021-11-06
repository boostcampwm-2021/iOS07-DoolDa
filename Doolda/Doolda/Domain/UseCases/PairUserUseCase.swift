//
//  PairUserUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/06.
//

import Combine
import Foundation

enum PairUserUseCaseError: LocalizedError {
    case notExistUser
    case myIdAndFriendIdAreTheSame
    case userAlreadyPairedWithAnotherUser
    case friendAlreadyPairedWithAnotherUser
    
    var errorDescription: String? {
        switch self {
        case .notExistUser:
            return "존재하지 않는 사용자입니다."
        case .myIdAndFriendIdAreTheSame:
            return "입력된 아이디가 내 아이디와 같습니다."
        case .userAlreadyPairedWithAnotherUser:
            return "이미 다른 유저와 친구가 맺어져 있습니다."
        case .friendAlreadyPairedWithAnotherUser:
            return "입력한 친구는 이미 다른 유저와 친구를 맺고 있습니다."
        }
    }
}

protocol PairUserUseCaseProtocol {
    var pairedUserPublisher: Published<User?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    func pair(user: User, friendId: DDID)
}
