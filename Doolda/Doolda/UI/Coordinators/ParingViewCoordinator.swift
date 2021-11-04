//
//  ParingViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/02.
//

import UIKit

class PairingViewCoordinator: Coordinator {
    private let myId: String
    
    init(presenter: UINavigationController, parent: Coordinator? = nil, myId: String) {
        self.myId = myId
        super.init(presenter: presenter, parent: parent)
    }
    
    override func start() {
        let userDefaultsPersistenceService = UserDefaultsPersistenceService()
        let firebaseNetworkService = FirebaseNetworkService()
        
        let userRepository = UserRepository(
            persistenceService: userDefaultsPersistenceService,
            networkService: firebaseNetworkService
        )

        let generatePairIdUseCase = GeneratePairIdUseCase(userRepository: userRepository)
        let refreshPairIdUseCase = RefreshPairIdUseCase(userRepository: userRepository)

        let viewModel = PairingViewModel(
            myId: self.myId,
            coordinatorDelegate: self,
            generatePairIdUseCase: generatePairIdUseCase,
            refreshPairIdUseCase: refreshPairIdUseCase
        )
        
        let viewController = PairingViewController(viewModel: viewModel)
        self.presenter.setViewControllers([viewController], animated: false)
    }
}

extension PairingViewCoordinator: PairingViewCoordinatorDelegate {
    func userDidPaired(myId: String, pairId: String) {
        let diaryViewCoordinator = DiaryViewCoordinator(presenter: self.presenter, parent: self, myId: myId, pairId: pairId)
        self.add(child: diaryViewCoordinator)
        diaryViewCoordinator.start()
    }
}
