//
//  PairUserUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/06.
//

import Combine
import Foundation

enum PairUserUseCaseError: LocalizedError {
    case userNotExists
    case myIdAndFriendIdAreTheSame
    case userAlreadyPairedWithAnotherUser
    case friendAlreadyPairedWithAnotherUser
    
    var errorDescription: String? {
        switch self {
        case .userNotExists:
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
    func pair(user: User)
}

final class PairUserUseCase: PairUserUseCaseProtocol {
    var pairedUserPublisher: Published<User?>.Publisher { self.$pairedUser }
    var errorPublisher: Published<Error?>.Publisher { self.$error }
    
    private let userRepository: UserRepositoryProtocol
    private let pairRepository: PairRepositoryProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    @Published private var pairedUser: User?
    @Published private var error: Error?
    
    init(userRepository: UserRepositoryProtocol, pairRepository: PairRepositoryProtocol) {
        self.userRepository = userRepository
        self.pairRepository = pairRepository
    }
    
    func pair(user: User, friendId: DDID) {
        guard user.id != friendId else {
            return self.error = PairUserUseCaseError.myIdAndFriendIdAreTheSame
        }
        
        Publishers.Zip(self.userRepository.fetchUser(user), self.userRepository.fetchUser(friendId))
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] user, friend in
                guard let self = self else { return }
                guard let user = user,
                      let friend = friend else {
                          return self.error = PairUserUseCaseError.userNotExists
                      }
                
                if self.isItPossibleToPair(user: user, with: friend) {
                    self.setUserPairId(user: user, friend: friend)
                }
            }
            .store(in: &cancellables)
    }

    func pair(user: User) {
        let pairId = user.id
        let user = User(id: user.id, pairId: pairId)

        Publishers.Zip(
            self.userRepository.setUser(user),
            self.pairRepository.setPairId(with: user)
        )
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                self.error = error
            } receiveValue: { user, _ in
                self.pairedUser = user
            }
            .store(in: &self.cancellables)
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

    private func setUserPairId(user: User, friend: User) {
        self.pairRepository.fetchRecentlyEditedUser(with: user)
            .sink { [weak self] completion in
                guard let self = self,
                      case .failure = completion else { return }
                
                let pairId = DDID()
                let user = User(id: user.id, pairId: pairId)
                let friend = User(id: friend.id, pairId: pairId)
                
                Publishers.Zip3(
                    self.userRepository.setUser(user),
                    self.userRepository.setUser(friend),
                    self.pairRepository.setPairId(with: friend)
                )
                    .sink { completion in
                        guard case .failure(let error) = completion else { return }
                        self.error = error
                    } receiveValue: { user, _, _ in
                        self.pairedUser = user
                    }
                    .store(in: &self.cancellables)
            } receiveValue: { [weak self] _ in
                self?.pairedUser = user
            }
            .store(in: &self.cancellables)
    }
}
