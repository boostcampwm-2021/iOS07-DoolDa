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

final class PairUserUseCase: PairUserUseCaseProtocol {
    var pairedUserPublisher: Published<User?>.Publisher { self.$pairedUser }
    var errorPublisher: Published<Error?>.Publisher { self.$error }
    
    private let userRepository: _UserRepositoryProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    @Published private var pairedUser: User?
    @Published private var error: Error?
    
    init(userRepository: _UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func pair(user: User, friendId: DDID) {
        guard user.id != friendId else {
            return self.error = PairUserUseCaseError.myIdAndFriendIdAreTheSame
        }
        
        Publishers.Zip(self.userRepository.fetchUser(user), self.userRepository.fetchUser(friendId))
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                self.error = error
            } receiveValue: { user, friend in
                // 의문사항: 1. user나 friend가 nil로 전달되는 경우는 네트워크 에러 케이스 아닌가?
                //         2. 존재하지 않는 친구 아이디 입력후 fetch 요청하면?
                //              (1, 2)-> 존재하지 않는 아이디를 전달했을 경우 nil 오는가?
                guard let user = user,
                      let friend = friend else {
                          return self.error = PairUserUseCaseError.notExistUser
                      }
                
                if self.isItPossibleToPair(user: user, with: friend) {
                    self.pairedUser = user
                }
            }
            .store(in: &cancellables)
    }
    
    private func isItPossibleToPair(user: User, with another: User) -> Bool {
        let pairIdsOfUsers = (user.pairId, another.pairId)
        
        switch pairIdsOfUsers {
        case let (user, another) where user == nil && another != nil:
            self.error = PairUserUseCaseError.friendAlreadyPairedWithAnotherUser
            return false
        case let (user, another) where user != nil && another == nil:
            self.error = PairUserUseCaseError.userAlreadyPairedWithAnotherUser
            return false
        case let (user, another) where user != nil && another != nil && user != another:
            self.error = PairUserUseCaseError.userAlreadyPairedWithAnotherUser
            return false
        default:
            return true
        }
    }
}
