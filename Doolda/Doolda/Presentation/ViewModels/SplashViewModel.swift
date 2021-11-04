//
//  SplashViewModel.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import Foundation

import Combine

final class SplashViewModel {
    @Published var networkError: Error?

    private var cancellables: Set<AnyCancellable> = []

    private let coordinatorDelegate: SplashViewCoordinatorDelegate
    private let getMyIdUseCase: GetMyIdUseCaseProtocol
    private let getPairIdUseCase: GetPairIdUseCaseProtocol
    private let generateMyIdUseCase: GenerateMyIdUseCaseProtocol
    
    init(coordinatorDelegate: SplashViewCoordinatorDelegate,
         getMyIdUseCase: GetMyIdUseCaseProtocol,
         getPairIdUseCase: GetPairIdUseCaseProtocol,
         generateMyIdUseCase: GenerateMyIdUseCaseProtocol) {
        self.coordinatorDelegate = coordinatorDelegate
        self.getMyIdUseCase = getMyIdUseCase
        self.getPairIdUseCase = getPairIdUseCase
        self.generateMyIdUseCase = generateMyIdUseCase
    }

    func viewDidLoad() {
        getMyId()
    }

    private func getMyId() {
        getMyIdUseCase.getMyId()
            .sink { [weak self] result in
                guard case .failure(_) = result else { return }
                self?.generateMyId()
            } receiveValue: { myId in
                self.getPairId(with: myId)
            }
            .store(in: &cancellables)
    }

    private func getPairId(with myId: String) {
        getPairIdUseCase.getPairId(for: myId)
            .sink { [weak self] result in
                guard case .failure(_) = result else { return }
                self?.coordinatorDelegate.userNotPaired(myId: myId)
            } receiveValue: { pairId in
                self.coordinatorDelegate.userAlreadyPaired(myId: myId, pairId: pairId)
            }
            .store(in: &cancellables)
    }

    private func generateMyId() {
        generateMyIdUseCase.savedIdPublisher
            .sink(receiveValue: { myId in
                guard let myId = myId else { return }
                self.coordinatorDelegate.userNotPaired(myId: myId)
            })
            .store(in: &cancellables)

        generateMyIdUseCase.errorPublisher
            .sink(receiveValue: { error in
                guard let error = error else { return }
                self.networkError = error
            })
            .store(in: &cancellables)

        generateMyIdUseCase.generate()
    }
}
