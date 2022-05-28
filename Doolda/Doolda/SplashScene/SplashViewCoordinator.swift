//
//  SplashViewCoordinator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import Combine
import UIKit

final class SplashViewCoordinator: BaseCoordinator {
    
    // MARK: - Nested enum
    
    enum Keys {
        static let user = "user"
        static let myId = "myId"
    }
    
    private var cancellables: Set<AnyCancellable> = []

    override init(identifier: UUID, presenter: UINavigationController) {
        super.init(identifier: identifier, presenter: presenter)
    }
    
    func start() {
        let userDefaultsPersistenceService = UserDefaultsPersistenceService.shared
        let firebaseNetworkService = FirebaseNetworkService.shared

        let userRespository = UserRepository(
            persistenceService: userDefaultsPersistenceService,
            networkService: firebaseNetworkService
        )
        let globalFontRepository = GlobalFontRepository(
            persistenceService: userDefaultsPersistenceService
        )
        
        let authenticateUseCase = AuthenticateUseCase()
        let getMyIdUseCase = GetMyIdUseCase(userRepository: userRespository)
        let getUserUseCase = GetUserUseCase(userRepository: userRespository)
        let globalFontUseCase = GlobalFontUseCase(globalFontRepository: globalFontRepository)
        
        let viewModel = SplashViewModel(
            sceneId: self.identifier,
            authenticateUseCase: authenticateUseCase,
            getMyIdUseCase: getMyIdUseCase,
            getUserUseCase: getUserUseCase,
            globalFontUseCase: globalFontUseCase
        )
        
        viewModel.loginPageRequested
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loginPageRequest()
            }
            .store(in: &self.cancellables)
        
        viewModel.agreementPageRequested
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.agreementPageRequest(user: user)
            }
            .store(in: &self.cancellables)

        viewModel.pairingPageRequested
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.pairingPageRequest(user: user)
            }
            .store(in: &self.cancellables)

        viewModel.diaryPageRequested
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.diaryPageRequest(user: user)
            }
            .store(in: &self.cancellables)

        let viewController = SplashViewController(viewModel: viewModel)
        self.presenter.pushViewController(viewController, animated: false)
    }
    
     private func loginPageRequest() {
         let identifier = UUID()
         let authenticationViewCoordinator = AuthenticationViewCoordinator(identifier: identifier, presenter: self.presenter)
         self.children[identifier] = authenticationViewCoordinator
         authenticationViewCoordinator.start()
     }
     
    private func agreementPageRequest(user: User) {
        let identifier = UUID()
        let agreementViewCoordinator = AgreementViewCoordinator(identifier: identifier, presenter: self.presenter, user: user)
        self.children[identifier] = agreementViewCoordinator
        agreementViewCoordinator.start()
    }
    
    private func pairingPageRequest(user: User) {
        let identifier = UUID()
        let paringViewCoordinator = PairingViewCoordinator(identifier: identifier, presenter: self.presenter, user: user)
        self.children[identifier] = paringViewCoordinator
        paringViewCoordinator.start()
    }

    private func diaryPageRequest(user: User) {
        let identifier = UUID()
        let diaryViewCoordinator = DiaryViewCoordinator(identifier: identifier, presenter: self.presenter, user: user)
        self.children[identifier] = diaryViewCoordinator
        diaryViewCoordinator.start()
    }
}
