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
    @Published private var user: User?
    
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
        self.bind()
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) { self.getMyId() }
    }

    private func bind() {
        self.$user
            .compactMap { $0 }
            .sink(receiveValue: { [weak self] user in
                if user.pairId?.ddidString.isEmpty == false {
                    self?.coordinatorDelegate.userAlreadyPaired(user: user)
                } else {
                    self?.coordinatorDelegate.userNotPaired(myId: user.id)
                }
            })
            .store(in: &self.cancellables)

        self.registerUserUseCase.registeredUserPublisher
            .compactMap { $0 }
            .sink(receiveValue: { [weak self] user in
                self?.user = user
            })
            .store(in: &self.cancellables)

        self.registerUserUseCase.errorPublisher
            .assign(to: \.error, on: self)
            .store(in: &self.cancellables)
    }

    private func getMyId() {
        self.getMyIdUseCase.getMyId()
            .sink(receiveValue: { [weak self] myId in
                guard let myId = myId else {
                    self?.registerUserUseCase.register()
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

}
