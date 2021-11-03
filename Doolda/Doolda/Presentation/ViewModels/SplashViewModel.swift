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
        // 식별코드 모두 있다면 coordinatorDelegate.presentDiaryViewController
        // 없다면 coordinatorDelegate.presentParingViewController
        getMyId()
    }

    private func getMyId() {
        getMyIdUseCase.getMyId()
            .sink { result in
                switch result {
                case .finished:
                    self.getPairId()
                case .failure(_):
                    self.coordinatorDelegate.presentParingViewController()
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

            } receiveValue: { pairId in

            }
            .store(in: &cancellables)
    }

    // 내 식별코드 가져오기
    // 내 식별코드가 있다면 그를 이용해 내 pairId를 가져온다
    // 두 가지중 하나라도 실패하면 paringViewController로 이동하는 플래그 설정
    // 모두 성공하면 DiaryViewcontroller로 이동

}
