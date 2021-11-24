//
//  PageDetailViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/24.
//

import UIKit

class PageDetailViewCoordinator: PageDetailViewCoordinatorProtocol {
    var presenter: UINavigationController
    private let pageEntity: PageEntity

    init(presenter: UINavigationController, pageEntity: PageEntity) {
        self.presenter = presenter
        self.pageEntity = pageEntity
    }

    func start() {
        let networkService = URLSessionNetworkService()
        let coreDataPersistenceService = CoreDataPersistenceService()
        let coreDataPageEntityPersistenceService = CoreDataPageEntityPersistenceService(coreDataPersistenceService: coreDataPersistenceService)
        let fileManagerPersistenceService = FileManagerPersistenceService()

        let rawPageRepository = RawPageRepository(
            networkService: networkService,
            coreDataPageEntityPersistenceService: coreDataPageEntityPersistenceService,
            fileManagerPersistenceService: fileManagerPersistenceService
        )

        let getRawPageUseCase = GetRawPageUseCase(rawPageRepository: rawPageRepository)

        let viewModel = PageDetaillViewModel(
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

    }

}
