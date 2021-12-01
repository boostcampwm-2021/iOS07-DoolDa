//
//  PageDetailViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/24.
//

import Combine
import UIKit

final class PageDetailViewCoordinator: CoordinatorProtocol {
    
    // MARK: - Nested enum
    
    enum Notifications {
        static let editPageRequested = Notification.Name("editPageRequested")
    }
    
    enum Keys {
        static let rawPageEntity = "rawPageEntity"
    }
    
    // MARK: - Public Properties
    
    var identifier: UUID
    var presenter: UINavigationController
    var children: [UUID : CoordinatorProtocol] = [:]
    
    // MARK: - Private Properties
    
    private let user: User
    private let pageEntity: PageEntity
    
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers
    
    init(identifier: UUID, presenter: UINavigationController, user: User, pageEntity: PageEntity) {
        self.identifier = identifier
        self.presenter = presenter
        self.user = user
        self.pageEntity = pageEntity
        bind()
    }

    // MARK: - Helpers
    
    private func bind() {
        NotificationCenter.default.publisher(for: Notifications.editPageRequested, object: nil)
            .compactMap { $0.userInfo?[Keys.rawPageEntity] as? RawPageEntity }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rawPageEntity in
                self?.editPageRequested(with: rawPageEntity)
            }
            .store(in: &self.cancellables)
    }
    
    // MARK: - Public Methods
    
    func start() {
        let networkService = URLSessionNetworkService.shared
        let coreDataPersistenceService = CoreDataPersistenceService.shared
        let coreDataPageEntityPersistenceService = CoreDataPageEntityPersistenceService(coreDataPersistenceService: coreDataPersistenceService)
        let fileManagerPersistenceService = FileManagerPersistenceService.shared

        let rawPageRepository = RawPageRepository(
            networkService: networkService,
            coreDataPageEntityPersistenceService: coreDataPageEntityPersistenceService,
            fileManagerPersistenceService: fileManagerPersistenceService
        )

        let getRawPageUseCase = GetRawPageUseCase(rawPageRepository: rawPageRepository)

        let viewModel = PageDetaillViewModel(
            user: self.user,
            pageEntity: self.pageEntity,
            getRawPageUseCase: getRawPageUseCase
        )

        let viewController = PageDetailViewController(viewModel: viewModel)
        self.presenter.topViewController?.navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: - Private Methods
    
    private func editPageRequested(with rawPageEntity: RawPageEntity) {
        let identifier = UUID()
        let coordinator = EditPageViewCoordinator(
            identifier: identifier,
            presenter: self.presenter,
            user: self.user,
            pageEntity: self.pageEntity,
            rawPageEntity: rawPageEntity
        )
        self.children[identifier] = coordinator
        coordinator.start()
    }
}
