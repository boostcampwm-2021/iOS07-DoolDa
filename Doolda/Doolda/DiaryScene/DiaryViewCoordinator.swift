//
//  DiaryViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/02.
//

import UIKit

class DiaryViewCoordinator: DiaryViewCoordinatorProtocol {
    
    var presenter: UINavigationController
    private let user: User
    
    init(presenter: UINavigationController, user: User) {
        self.presenter = presenter
        self.user = user
    }
    
    func start() {
        let urlSessionNetworkService = URLSessionNetworkService()
        let coreDataPersistenceService = CoreDataPersistenceService()
        let coreDataPageEntityPersistenceService = CoreDataPageEntityPersistenceService(coreDataPersistenceService: coreDataPersistenceService)
        let fileManagerPersistenceService = FileManagerPersistenceService()
        
        let pairRepository = PairRepository(networkService: urlSessionNetworkService)
        let pageRepository = PageRepository(
            urlSessionNetworkService: urlSessionNetworkService,
            pageEntityPersistenceService: coreDataPageEntityPersistenceService
        )
        
        let rawPageRepository = RawPageRepository(
            networkService: urlSessionNetworkService,
            fileManagerPersistenceService: fileManagerPersistenceService
        )
        
        let fcmTokenRepository = FCMTokenRepository(urlSessionNetworkService: urlSessionNetworkService)
        let firebaseMessageRepository = FirebaseMessageRepository(urlSessionNetworkService: urlSessionNetworkService)
        
        let checkMyTurnUseCase = CheckMyTurnUseCase(pairRepository: pairRepository)
        let getPageUseCase = GetPageUseCase(pageRepository: pageRepository)
        let getRawPageUseCase = GetRawPageUseCase(rawPageRepository: rawPageRepository)
        let firebaseMessageUseCase = FirebaseMessageUseCase(
            fcmTokenRepository: fcmTokenRepository,
            firebaseMessageRepository: firebaseMessageRepository
        )
        
        let viewModel = DiaryViewModel(
            user: self.user,
            coordinator: self,
            checkMyTurnUseCase: checkMyTurnUseCase,
            getPageUseCase: getPageUseCase,
            getRawPageUseCase: getRawPageUseCase,
            firebaseMessageUseCase: firebaseMessageUseCase
        )
        
        DispatchQueue.main.async {
            let viewController = DiaryViewController(viewModel: viewModel)
            self.presenter.setViewControllers([viewController], animated: false)
        }
    }
    
    func editPageRequested() {
        let coordinator = EditPageViewCoordinator(presenter: self.presenter, user: self.user)
        coordinator.start()
    }
    
    func settingsPageRequested() {
        let coordinator = SettingsViewCoordinator(presenter: self.presenter)
        coordinator.start()
    }
    
    func filteringSheetRequested(authorFilter: DiaryAuthorFilter, orderFilter: DiaryOrderFilter) {
        let viewModel = FilterOptionBottomSheetViewModel(authorFilter: authorFilter, orderFilter: orderFilter)
        let delegate = self.presenter.topViewController as? DiaryViewController
        let viewController = FilterOptionBottomSheetViewController(viewModel: viewModel, delegate: delegate)
        self.presenter.present(viewController, animated: false)
    }
}
