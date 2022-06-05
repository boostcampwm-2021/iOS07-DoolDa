//
//  PairingViewModel.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/02.
//

import Combine
import Foundation

protocol PairingViewModelInput {
    var friendIdInput: String { get set }
    func pairButtonDidTap()
    func pairSkipButtonDidTap()
    func refreshButtonDidTap()
    func userPairedWithFriendNotificationDidReceived()
    func deinitRequested()
}

protocol PairingViewModelOutput {
    var myId: AnyPublisher<String, Never> { get }
    var isFriendIdValid: AnyPublisher<Bool, Never> { get }
    var pairedUserPublisher: AnyPublisher<User?, Never> { get }
    var isPairedByRefreshPublisher: AnyPublisher<Bool, Never> { get }
    var errorPublisher: AnyPublisher<Error?, Never> { get }
}

typealias PairingViewModelProtocol = PairingViewModelInput & PairingViewModelOutput

final class PairingViewModel: PairingViewModelProtocol {
    
    @Published var friendIdInput: String = ""
    
    lazy var myId: AnyPublisher<String, Never> = Just(user.id)
        .map { $0.ddidString }
        .eraseToAnyPublisher()
    
    lazy var isFriendIdValid: AnyPublisher<Bool, Never> = $friendIdInput
        .compactMap { DDID.isValid(ddidString: $0) }
        .eraseToAnyPublisher()
    
    var pairedUserPublisher: AnyPublisher<User?, Never> { self.$pairedUser.eraseToAnyPublisher() }
    var isPairedByRefreshPublisher: AnyPublisher<Bool, Never> { self.$isPairedByRefresh.eraseToAnyPublisher() }
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }

    private let sceneId: UUID
    private let user: User
    private let pairUserUseCase: PairUserUseCaseProtocol
    private let refreshUserUseCase: RefreshUserUseCaseProtocol
    private let firebaseMessageUseCase: FirebaseMessageUseCaseProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    @Published private var pairedUser: User?
    @Published private var isPairedByRefresh: Bool = false
    @Published private var error: Error?
    
    init(
        sceneId: UUID,
        user: User,
        pairUserUseCase: PairUserUseCaseProtocol,
        refreshUserUseCase: RefreshUserUseCaseProtocol,
        firebaseMessageUseCase: FirebaseMessageUseCaseProtocol
    ) {
        self.sceneId = sceneId
        self.user = user
        self.pairUserUseCase = pairUserUseCase
        self.refreshUserUseCase = refreshUserUseCase
        self.firebaseMessageUseCase = firebaseMessageUseCase
        bind()
    }
    
    private func bind() {
        self.pairUserUseCase.errorPublisher
            .assign(to: &$error)
        
        self.refreshUserUseCase.errorPublisher
            .assign(to: &$error)
        
        self.pairUserUseCase.pairedUserPublisher
            .compactMap { $0 }
            .sink { [weak self] user in
                self?.pairedUser = user
                if let friendId = user.friendId, friendId != user.id {
                    self?.firebaseMessageUseCase.sendMessage(to: friendId, message: PushMessageEntity.userPairedWithFriend)
                }
            }
            .store(in: &self.cancellables)
        
        self.refreshUserUseCase.refreshedUserPublisher
            .compactMap { $0 }
            .sink { [weak self] user in
                if user.pairId != nil {
                    self?.pairedUser = user
                } else {
                    self?.isPairedByRefresh = false
                }
            }
            .store(in: &self.cancellables)
        
        self.refreshUserUseCase.observe(for: self.user)
    }
    
    func pairButtonDidTap() {
        guard let friendId = DDID(from: self.friendIdInput) else { return }
        self.pairUserUseCase.pair(user: self.user, friendId: friendId)
    }

    func pairSkipButtonDidTap() {
        self.pairUserUseCase.pair(user: self.user)
    }
    
    func refreshButtonDidTap() {
        self.refreshUserUseCase.refresh(for: self.user)
    }
    
    func userPairedWithFriendNotificationDidReceived() {
        self.refreshUserUseCase.refresh(for: self.user)
    }
    
    func deinitRequested() {
        NotificationCenter.default.post(
            name: BaseCoordinator.Notifications.coordinatorRemoveFromParent,
            object: nil,
            userInfo: [BaseCoordinator.Keys.sceneId: self.sceneId]
        )
    }
}
