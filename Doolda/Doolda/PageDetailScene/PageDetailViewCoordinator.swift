//
//  PageDetailViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/24.
//

import UIKit

final class PageDetailViewCoordinator: PageDetailViewCoordinatorProtocol {
    var identifier: UUID
    var presenter: UINavigationController
    var children: [UUID : CoordinatorProtocol] = [:]
    private let user: User
    private let pageEntity: PageEntity

    init(identifier: UUID, presenter: UINavigationController, user: User, pageEntity: PageEntity) {
        self.identifier = identifier
        self.presenter = presenter
        self.user = user
        self.pageEntity = pageEntity
    }

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
            coordinator: self,
            getRawPageUseCase: getRawPageUseCase
        )

        DispatchQueue.main.async {
            let viewController = PageDetailViewController(viewModel: viewModel)
            self.presenter.topViewController?.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    func editPageRequested(with rawPageEntity: RawPageEntity) {
        let identifier = UUID()
        let coordinator = EditPageViewCoordinator(identifier: identifier, presenter: self.presenter, user: self.user, pageEntity: self.pageEntity, rawPageEntity: rawPageEntity)
        self.children[identifier] = coordinator
        coordinator.start()
    }

}
