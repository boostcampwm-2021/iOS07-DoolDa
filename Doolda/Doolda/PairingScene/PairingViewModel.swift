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
    func deinitRequested()
}

protocol PairingViewModelOutput {
    var myId: AnyPublisher<String, Never> { get }
    var isFriendIdValid: AnyPublisher<Bool, Never> { get }
    var pairedUserPublisher: PassthroughSubject<User?, Never> { get }
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
    
    var pairedUserPublisher = PassthroughSubject<User?, Never>()
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }

    private let sceneId: UUID
    private let user: User
    private let pairUserUseCase: PairUserUseCaseProtocol
    private let refreshUserUseCase: RefreshUserUseCaseProtocol
    private let firebaseMessageUseCase: FirebaseMessageUseCaseProtocol
    
    private var cancellables: Set<AnyCancellable> = []
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
        
        self.pairUserUseCase.pairedUserPublisher
            .compactMap { $0 }
            .sink { [weak self] user in
                self?.validatePairedUser(user)
            }
            .store(in: &self.cancellables)
        
        self.refreshUserUseCase.observe(for: self.user)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] observedUser in
                self?.validatePairedUser(observedUser)
            }
            .store(in: &self.cancellables)
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
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] refreshedUser in
                self?.validatePairedUser(refreshedUser)
            }
            .store(in: &self.cancellables)
    }
    
    func deinitRequested() {
        NotificationCenter.default.post(
            name: BaseCoordinator.Notifications.coordinatorRemoveFromParent,
            object: nil,
            userInfo: [BaseCoordinator.Keys.sceneId: self.sceneId]
        )
    }
    
    private func validatePairedUser(_ user: User) {
        guard let friendId = user.friendId else { return }
        if friendId != user.id {
            self.firebaseMessageUseCase.sendMessage(to: friendId, message: .userPairedWithFriend)
        }
        self.pairedUserPublisher.send(user)
    }
}
