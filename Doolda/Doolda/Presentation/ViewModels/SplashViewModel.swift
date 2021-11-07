//
//  SplashViewModel.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import Combine
import Foundation

final class SplashViewModel {
    @Published var error: Error?

    private let coordinatorDelegate: SplashViewCoordinatorDelegate
    private let getMyIdUseCase: GetMyIdUseCaseProtocol
    private let getUserUseCase: GetUserUseCaseProtocol
    private let registerUserUseCase: RegisterUserUseCaseProtocol

    private var cancellables: Set<AnyCancellable> = []
    @Published var user: User?
    
    init(
        coordinatorDelegate: SplashViewCoordinatorDelegate,
        getMyIdUseCase: GetMyIdUseCaseProtocol,
        getUserUseCase: GetUserUseCaseProtocol,
        registerUserUseCase: RegisterUserUseCaseProtocol
    ) {
        self.coordinatorDelegate = coordinatorDelegate
        self.getMyIdUseCase = getMyIdUseCase
        self.getUserUseCase = getUserUseCase
        self.registerUserUseCase = registerUserUseCase
    }

    func prepareUserInfo() {
        self.getMyId()
    }

    private func bind() {
        self.$user
            .sink(receiveValue: { [weak self] user in
                guard let user = user else {
                    self?.registerUserUseCase.register() //
                    return
                }
                if user.pairId == nil || user.pairId.isEmpty {
                    self?.coordinatorDelegate.userNotPaired(myId: user.id)
                }
                else {
                    self?.coordinatorDelegate.userAlreadyPaired(user: user)
                }
            })
            .store(in: &self.cancellables)
    }

    private func getMyId() {
        self.getMyIdUseCase.getMyId()
            .sink(receiveValue: { [weak self] myId in
                guard let myId = myId else {
                    self?.generateMyId()
                    return
                }
                self?.getUser(with: myId)
            })
            .store(in: &self.cancellables)
    }

    private func getUser(with myId: DDID) {
        self.getUserUseCase.getUser(for: myId)
            .sink { [weak self] result in
                guard case .failure(let error) = result else { return }
                self?.error = error
            } receiveValue: { [weak self] user in
                self?.user = user
            }
            .store(in: &self.cancellables)
    }

    private func generateMyId() {
        self.generateMyIdUseCase.savedIdPublisher
            .sink(receiveValue: { [weak self] myId in
                guard let myId = myId else { return }
                self?.coordinatorDelegate.userNotPaired(myId: myId)
            })
            .store(in: &self.cancellables)

        self.generateMyIdUseCase.errorPublisher
            .sink(receiveValue: { [weak self] error in
                guard let error = error else { return }
                self?.error = error
            })
            .store(in: &self.cancellables)

        self.generateMyIdUseCase.generate()
    }
}
