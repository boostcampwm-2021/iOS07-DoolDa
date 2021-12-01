//
//  DiaryViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/02.
//

import UIKit

final class DiaryViewCoordinator: DiaryViewCoordinatorProtocol {
    var identifier: UUID
    var presenter: UINavigationController
    var children: [UUID : CoordinatorProtocol] = [:]
    
    private let user: User
    
    init(identifier: UUID, presenter: UINavigationController, user: User) {
        self.identifier = identifier
        self.presenter = presenter
        self.user = user
    }
    
    func start() {
        let urlSessionNetworkService = URLSessionNetworkService.shared
        let coreDataPersistenceService = CoreDataPersistenceService.shared
        let coreDataPageEntityPersistenceService = CoreDataPageEntityPersistenceService(coreDataPersistenceService: coreDataPersistenceService)
        let fileManagerPersistenceService = FileManagerPersistenceService.shared
        
        let pairRepository = PairRepository(networkService: urlSessionNetworkService)
        let pageRepository = PageRepository(
            urlSessionNetworkService: urlSessionNetworkService,
            pageEntityPersistenceService: coreDataPageEntityPersistenceService
        )
        
        let rawPageRepository = RawPageRepository(
            networkService: urlSessionNetworkService,
            coreDataPageEntityPersistenceService: coreDataPageEntityPersistenceService,
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
        let identifier = UUID()
        let coordinator = EditPageViewCoordinator(identifier: identifier, presenter: self.presenter, user: self.user)
        coordinator.start()
    }
    
    func settingsPageRequested() {
        let identifier = UUID()
        let coordinator = SettingsViewCoordinator(identifier: identifier, presenter: self.presenter, user: self.user)
        coordinator.start()
    }
    
    func filteringSheetRequested(authorFilter: DiaryAuthorFilter, orderFilter: DiaryOrderFilter) {
        let viewModel = FilterOptionBottomSheetViewModel(authorFilter: authorFilter, orderFilter: orderFilter)
        let delegate = self.presenter.topViewController as? DiaryViewController
        let viewController = FilterOptionBottomSheetViewController(viewModel: viewModel, delegate: delegate)
        self.presenter.present(viewController, animated: false)
    }
    
    func pageDetailRequested(pageEntity: PageEntity) {
        let identifier = UUID()
        let coordinator = PageDetailViewCoordinator(identifier: identifier, presenter: self.presenter, user: self.user, pageEntity: pageEntity)
        self.children[identifier] = coordinator
        coordinator.start()
    }
}
