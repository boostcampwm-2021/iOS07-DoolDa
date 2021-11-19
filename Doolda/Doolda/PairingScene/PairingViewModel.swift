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
}

protocol PairingViewModelOutput {
    var myId: AnyPublisher<String, Never> { get }
    var isFriendIdValid: AnyPublisher<Bool, Never> { get }
    var pairedUserPublisher: Published<User?>.Publisher { get }
    var isPairedByRefreshPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
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
    
    var pairedUserPublisher: Published<User?>.Publisher { self.$pairedUser }
    var isPairedByRefreshPublisher: Published<Bool>.Publisher { self.$isPairedByRefresh }
    var errorPublisher: Published<Error?>.Publisher { self.$error }

    private let user: User
    private let coordinator: PairingViewCoordinatorProtocol
    private let pairUserUseCase: PairUserUseCaseProtocol
    private let refreshUserUseCase: RefreshUserUseCaseProtocol
    private var cancellables: Set<AnyCancellable> = []
    @Published private var pairedUser: User?
    @Published private var isPairedByRefresh: Bool = false
    @Published private var error: Error?
    
    init(
        user: User,
        coordinator: PairingViewCoordinatorProtocol,
        pairUserUseCase: PairUserUseCaseProtocol,
        refreshUserUseCase: RefreshUserUseCaseProtocol
    ) {
        self.user = user
        self.coordinator = coordinator
        self.pairUserUseCase = pairUserUseCase
        self.refreshUserUseCase = refreshUserUseCase
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
                self?.coordinator.userDidPaired(user: user)
            }
            .store(in: &self.cancellables)
        
        self.refreshUserUseCase.refreshedUserPublisher
            .compactMap { $0 }
            .sink { [weak self] user in
                if user.pairId != nil {
                    self?.coordinator.userDidPaired(user: user)
                } else {
                    self?.isPairedByRefresh = false
                }
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
    }
}
