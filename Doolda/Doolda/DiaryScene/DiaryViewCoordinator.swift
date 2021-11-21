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
        
        let checkMyTurnUseCase = CheckMyTurnUseCase(pairRepository: pairRepository)
        let getPageUseCase = GetPageUseCase(pageRepository: pageRepository)
        let getRawPageUseCase = GetRawPageUseCase(rawPageRepository: rawPageRepository)
        
        let viewModel = DiaryViewModel(
            user: self.user,
            coordinator: self,
            checkMyTurnUseCase: checkMyTurnUseCase,
            getPageUseCase: getPageUseCase,
            getRawPageUseCase: getRawPageUseCase
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
    }
    
    func filteringSheetRequested() {
        let delegate = self.presenter.topViewController as? DiaryViewController
        let viewController = FilterOptionBottomSheetViewController(delegate: delegate)
        self.presenter.present(viewController, animated: false)
    }
}
