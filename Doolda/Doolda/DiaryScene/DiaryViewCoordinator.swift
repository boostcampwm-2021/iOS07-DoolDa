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
        self.bind()
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
            sceneId: self.identifier,
            user: self.user,
            checkMyTurnUseCase: checkMyTurnUseCase,
            getPageUseCase: getPageUseCase,
            getRawPageUseCase: getRawPageUseCase,
            firebaseMessageUseCase: firebaseMessageUseCase
        )
        
        let viewController = DiaryViewController(viewModel: viewModel)
        self.presenter.setViewControllers([viewController], animated: false)
    }
    
    private func bind() {
        NotificationCenter.default.publisher(for: Notifications.addPageRequested, object: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.editPageRequested()
            }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: Notifications.settingsPageRequested, object: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.settingsPageRequested()
            }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: Notifications.pageDetailRequested, object: nil)
            .receive(on: DispatchQueue.main)
            .compactMap { $0.userInfo?[Keys.pageEntity] as? PageEntity }
            .sink { [weak self] pageEntity in
                self?.pageDetailRequested(pageEntity: pageEntity)
            }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: Notifications.filteringSheetRequested, object: nil)
            .receive(on: DispatchQueue.main)
            .compactMap { ($0.userInfo?[Keys.authorFilter] as? DiaryAuthorFilter, $0.userInfo?[Keys.orderFilter] as? DiaryOrderFilter) }
            .sink { [weak self] filters in
                guard let authorFilter = filters.0,
                      let orderFilter = filters.1 else { return }
                self?.filteringSheetRequested(authorFilter: authorFilter, orderFilter: orderFilter)
            }
            .store(in: &self.cancellables)
    }
    
    private func editPageRequested() {
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
