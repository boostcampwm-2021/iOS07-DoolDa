//
//  DiaryViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/02.
//

import Combine
import UIKit

final class DiaryViewCoordinator: BaseCoordinator {
    
    // MARK: - Nested enum
    
    enum Notifications {
        static let pageDetailRequested = Notification.Name("pageDetailRequested")
        static let addPageRequested = Notification.Name("addPageRequested")
        static let settingsPageRequested = Notification.Name("settingsPageRequested")
        static let filteringSheetRequested = Notification.Name("filteringSheetRequested")
    }
    
    enum Keys {
        static let pageEntity = "pageEntity"
        static let authorFilter = "authorFilter"
        static let orderFilter = "orderFilter"
    }
    
    private let user: User
    private var cancellables: Set<AnyCancellable> = []
    
    init(identifier: UUID, presenter: UINavigationController, user: User) {
        self.user = user
        super.init(identifier: identifier, presenter: presenter)
    }
    
    func start() {
        let urlSessionNetworkService = URLSessionNetworkService.shared
        let firebaseNetworkService = FirebaseNetworkService.shared
        let coreDataPersistenceService = CoreDataPersistenceService.shared
        let coreDataPageEntityPersistenceService = CoreDataPageEntityPersistenceService(coreDataPersistenceService: coreDataPersistenceService)
        let fileManagerPersistenceService = FileManagerPersistenceService.shared
        
        let pairRepository = PairRepository(networkService: firebaseNetworkService)
        let pageRepository = PageRepository(
            networkService: FirebaseNetworkService.shared,
            pageEntityPersistenceService: coreDataPageEntityPersistenceService
        )
        
        let rawPageRepository = RawPageRepository(
            networkService: FirebaseNetworkService.shared,
            coreDataPageEntityPersistenceService: coreDataPageEntityPersistenceService,
            fileManagerPersistenceService: fileManagerPersistenceService
        )
        
        let fcmTokenRepository = FCMTokenRepository.shared
        let firebaseMessageRepository = FirebaseMessageRepository(urlSessionNetworkService: urlSessionNetworkService)
        
        let checkMyTurnUseCase = CheckMyTurnUseCase(pairRepository: pairRepository)
        let getPageUseCase = GetPageUseCase(pageRepository: pageRepository)
        let getRawPageUseCase = GetRawPageUseCase(rawPageRepository: rawPageRepository)
        let firebaseMessageUseCase = FirebaseMessageUseCase(
            fcmTokenRepository: fcmTokenRepository,
            firebaseMessageRepository: firebaseMessageRepository
        )
        
        let viewModel = DiaryViewModel(
            sceneId: self.identifier,
            user: self.user,
            checkMyTurnUseCase: checkMyTurnUseCase,
            getPageUseCase: getPageUseCase,
            getRawPageUseCase: getRawPageUseCase,
            firebaseMessageUseCase: firebaseMessageUseCase
        )
        
        viewModel.addPageRequested
            .sink { [weak self]_ in
                self?.editPageRequested()
            }
            .store(in: &self.cancellables)
        
        viewModel.settingsPageRequested
            .sink { [weak self] _ in
                self?.settingsPageRequested()
            }
            .store(in: &self.cancellables)

        viewModel.pageDetailRequested
            .sink { [weak self] pageEntity in
                self?.pageDetailRequested(pageEntity: pageEntity)
            }
            .store(in: &self.cancellables)
        
        viewModel.filteringSheetRequested
            .sink { [weak self] authorFilter, orderFilter in
                self?.filteringSheetRequested(authorFilter: authorFilter, orderFilter: orderFilter)
            }
            .store(in: &self.cancellables)

        let viewController = DiaryViewController(viewModel: viewModel)
        self.presenter.setViewControllers([viewController], animated: false)
    }
    
    private func editPageRequested() {
        // Check if it's ok to request new editing page
        guard !(self.children.contains { _, coordinator in
            guard coordinator as? EditPageViewCoordinator != nil else { return false }
            return true
        }) else { return }
        
        let identifier = UUID()
        let coordinator = EditPageViewCoordinator(identifier: identifier, presenter: self.presenter, user: self.user)
        self.children[identifier] = coordinator
        coordinator.start()
    }
    
    private func settingsPageRequested() {
        let identifier = UUID()
        let coordinator = SettingsViewCoordinator(identifier: identifier, presenter: self.presenter, user: self.user)
        self.children[identifier] = coordinator
        coordinator.start()
    }
    
    private func filteringSheetRequested(authorFilter: DiaryAuthorFilter, orderFilter: DiaryOrderFilter) {
        let viewModel = FilterOptionBottomSheetViewModel(authorFilter: authorFilter, orderFilter: orderFilter)
        let delegate = self.presenter.topViewController as? DiaryViewController
        let viewController = FilterOptionBottomSheetViewController(viewModel: viewModel, delegate: delegate)
        self.presenter.present(viewController, animated: false)
    }
    
    private func pageDetailRequested(pageEntity: PageEntity) {
        let identifier = UUID()
        let coordinator = PageDetailViewCoordinator(identifier: identifier, presenter: self.presenter, user: self.user, pageEntity: pageEntity)
        self.children[identifier] = coordinator
        coordinator.start()
    }
}
