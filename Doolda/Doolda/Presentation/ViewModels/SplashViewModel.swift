//
//  SplashViewModel.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import Foundation

import Combine

final class SplashViewModel {
    var myId: String?
    var pairId: String?
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
            .sink { result in
                switch result {
                case .finished:
                    self.getPairId()
                case .failure(_):
                    self.generateMyId()
                }
            } receiveValue: { myId in
                self.myId = myId
            }
            .store(in: &cancellables)
    }

    private func getPairId() {
        guard let myId = self.myId else { return }
        getPairIdUseCase.getPairId(with: myId)
            .sink { result in
                switch result {
                case .finished:
                    self.coordinatorDelegate.presentDiaryViewController()
                case .failure(_):
                    self.coordinatorDelegate.presentParingViewController()
                }
            } receiveValue: { pairId in
                self.pairId = pairId
            }
            .store(in: &cancellables)
    }

    private func generateMyId() {
        generateMyIdUseCase.generateMyId()
            .sink { result in
                switch result {
                case .finished:
                    self.coordinatorDelegate.presentParingViewController()
                case .failure(let error):
                    self.networkError = error
                }
            } receiveValue: { myId in
                self.myId = myId
            }
            .store(in: &cancellables)
    }
}
