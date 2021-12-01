//
//  SettingsViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/21.
//

import Combine
import UIKit

final class SettingsViewCoordinator: CoordinatorProtocol {

    // MARK: - Nested enum

    enum Notifications {
        static let fontPickerSheetRequested = Notification.Name("fontPickerSheetRequested")
        static let informationViewRequested = Notification.Name("informationViewRequested")
    }

    enum Keys {
        static let infoType = "infoType"
    }

    // MARK: - Public Properties

    var identifier: UUID
    var presenter: UINavigationController
    var children: [UUID : CoordinatorProtocol] = [:]

    // MARK: - Private Properties

    private let user: User

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers

    init(identifier: UUID, presenter: UINavigationController, user: User) {
        self.identifier = identifier
        self.presenter = presenter
        self.user = user
        self.bind()
    }

    // MARK: - Helpers

    private func bind() {
        NotificationCenter.default.publisher(for: Notifications.fontPickerSheetRequested, object: nil)
            .sink { [weak self] _ in
                self?.fontPickerSheetRequested()
            }
            .store(in: &self.cancellables)

        NotificationCenter.default.publisher(for: Notifications.informationViewRequested, object: nil)
            .compactMap { $0.userInfo?[Keys.infoType] as? DooldaInfoType }
            .sink { [weak self] infoType in
                self?.informationViewRequested(for: infoType)
            }
            .store(in: &self.cancellables)
    }

    // MARK: - Public Methods

    func start() {
        DispatchQueue.main.async {
            let userDefaultsPersistenceService = UserDefaultsPersistenceService.shared
            let urlSessionNetworkService = URLSessionNetworkService.shared

            let globalFontRepository = GlobalFontRepository(persistenceService: userDefaultsPersistenceService)
            let pushNotificationStateRepository = PushNotificationStateRepository(persistenceService: userDefaultsPersistenceService)
            let userRepository = UserRepository(
                persistenceService: userDefaultsPersistenceService,
                networkService: urlSessionNetworkService
            )
            let pairRepository = PairRepository(networkService: urlSessionNetworkService)
            let fcmTokenRepository = FCMTokenRepository(urlSessionNetworkService: urlSessionNetworkService)
            let firebaseMessageRepository = FirebaseMessageRepository(urlSessionNetworkService: urlSessionNetworkService)

            let globalFontUseCase = GlobalFontUseCase(globalFontRepository: globalFontRepository)
            let pushNotificationStateUseCase = PushNotificationStateUseCase(pushNotificationStateRepository: pushNotificationStateRepository)
            let unpairUserUseCase = UnpairUserUseCase(userRepository: userRepository, pairRepository: pairRepository)
            let firebaseMessageUseCase = FirebaseMessageUseCase(
                fcmTokenRepository: fcmTokenRepository,
                firebaseMessageRepository: firebaseMessageRepository
            )

            let viewModel = SettingsViewModel(
                user: self.user,
                globalFontUseCase: globalFontUseCase,
                unpairUserUseCase: unpairUserUseCase,
                pushNotificationStateUseCase: pushNotificationStateUseCase,
                firebaseMessageUseCase: firebaseMessageUseCase
            )
            let viewController = SettingsViewController(viewModel: viewModel)
            self.presenter.pushViewController(viewController, animated: true)
        }
    }

    // MARK: - Private Methods

    private func fontPickerSheetRequested() {
        guard let settingsViewController = self.presenter.topViewController as? SettingsViewController else { return }
        let fontPickerSheet = FontPickerViewController(delegate: settingsViewController)
        settingsViewController.present(fontPickerSheet, animated: false, completion: nil)
    }

    private func informationViewRequested(for option: DooldaInfoType) {
        let viewController = InformationViewController()
        viewController.titleText = option.title

        if option == .contributor {
            // FIXME: 만든 사람들 이미지를 넣어야함!!
            // viewController.image = UIImage.contributorImage
        } else {
            viewController.contentText = option.content
        }
        self.presenter.topViewController?.navigationController?.pushViewController(viewController, animated: true)
    }

}
