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
    private let getPairIdUseCase: GetPairIdUseCaseProtocol
    private let generateMyIdUseCase: GenerateMyIdUseCaseProtocol

    private var cancellables: Set<AnyCancellable> = []
    
    init(
        coordinatorDelegate: SplashViewCoordinatorDelegate,
         getMyIdUseCase: GetMyIdUseCaseProtocol,
         getPairIdUseCase: GetPairIdUseCaseProtocol,
         generateMyIdUseCase: GenerateMyIdUseCaseProtocol
    ) {
        self.coordinatorDelegate = coordinatorDelegate
        self.getMyIdUseCase = getMyIdUseCase
        self.getPairIdUseCase = getPairIdUseCase
        self.generateMyIdUseCase = generateMyIdUseCase
    }

    func prepareUserInfo() {
        self.getMyId()
    }

    private func getMyId() {
        self.getMyIdUseCase.getMyId()
            .sink { [weak self] result in
                guard case .failure = result else { return }
                self?.generateMyId()
            } receiveValue: { [weak self] myId in
                self?.getPairId(with: myId)
            }
            .store(in: &self.cancellables)
    }

    private func getPairId(with myId: String) {
        self.getPairIdUseCase.getPairId(for: myId)
            .sink { [weak self] result in
                guard case .failure(let error) = result else { return }
                self?.error = error
            } receiveValue: { [weak self] pairId in
                if pairId.isEmpty {
                    self?.coordinatorDelegate.userNotPaired(myId: myId)
                }
                self?.coordinatorDelegate.userAlreadyPaired(myId: myId, pairId: pairId)
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
