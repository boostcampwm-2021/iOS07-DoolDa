//
//  SettingsViewModel.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/22.
//

import Combine
import Foundation

protocol SettingsViewModelInput {
    func settingsViewDidLoad()
    func fontTypeDidTap()
    func fontTypeDidChanged(_ fontName: String)
    func pushNotificationDidToggle(_ isOn: Bool)
    func openSourceLicenseDidTap()
    func privacyPolicyDidTap()
    func contributorDidTap()
    func unpairButtonDidTap()
    func deinitRequested()
}

protocol SettingsViewModelOutput {
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    var pushNotificationStatePublisher: AnyPublisher<Bool?, Never> { get }
    var selectedFontPublisher: AnyPublisher<FontType?, Never> { get }
}

typealias SettingsViewModelProtocol = SettingsViewModelInput & SettingsViewModelOutput

final class SettingsViewModel: SettingsViewModelProtocol {
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }
    var pushNotificationStatePublisher: AnyPublisher<Bool?, Never> { self.$isPushNotificationOn.eraseToAnyPublisher() }
    var selectedFontPublisher: AnyPublisher<FontType?, Never> { self.$selectedFont.eraseToAnyPublisher() }

    private let sceneId: UUID
    private let user: User
    private let globalFontUseCase: GlobalFontUseCaseProtocol
    private let unpairUserUseCase: UnpairUserUseCaseProtocol
    private let pushNotificationStateUseCase: PushNotificationStateUseCaseProtocol
    private let firebaseMessageUseCase: FirebaseMessageUseCaseProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    @Published private var error: Error?
    @Published private var isPushNotificationOn: Bool?
    @Published private var selectedFont: FontType?

    init(
        sceneId: UUID,
        user: User,
        globalFontUseCase: GlobalFontUseCaseProtocol,
        unpairUserUseCase: UnpairUserUseCaseProtocol,
        pushNotificationStateUseCase: PushNotificationStateUseCaseProtocol,
        firebaseMessageUseCase: FirebaseMessageUseCaseProtocol
    ) {
        self.sceneId = sceneId
        self.user = user
        self.globalFontUseCase = globalFontUseCase
        self.unpairUserUseCase = unpairUserUseCase
        self.pushNotificationStateUseCase = pushNotificationStateUseCase
        self.firebaseMessageUseCase = firebaseMessageUseCase
    }

    func settingsViewDidLoad() {
        self.isPushNotificationOn = self.pushNotificationStateUseCase.getPushNotificationState()
        self.selectedFont = self.globalFontUseCase.getGlobalFont()
    }

    func fontTypeDidTap() {
        NotificationCenter.default.post(
            name: SettingsViewCoordinator.Notifications.fontPickerSheetRequested,
            object: nil
        )
    }

    func fontTypeDidChanged(_ fontName: String) {
        self.globalFontUseCase.setGlobalFont(with: fontName)
        self.globalFontUseCase.saveGlobalFont(as: fontName)
        self.selectedFont = FontType(fontName: fontName)
    }

    func pushNotificationDidToggle(_ isOn: Bool) {
        self.pushNotificationStateUseCase.setPushNotificationState(as: isOn)
    }

    func openSourceLicenseDidTap() {
        NotificationCenter.default.post(
            name: SettingsViewCoordinator.Notifications.informationViewRequested,
            object: nil,
            userInfo: [SettingsViewCoordinator.Keys.infoType: DooldaInfoType.openSourceLicense]
        )
    }

    func privacyPolicyDidTap() {
        NotificationCenter.default.post(
            name: SettingsViewCoordinator.Notifications.informationViewRequested,
            object: nil,
            userInfo: [SettingsViewCoordinator.Keys.infoType: DooldaInfoType.privacyPolicy]
        )
    }

    func contributorDidTap() {
        NotificationCenter.default.post(
            name: SettingsViewCoordinator.Notifications.informationViewRequested,
            object: nil,
            userInfo: [SettingsViewCoordinator.Keys.infoType: DooldaInfoType.contributor]
        )
    }
    
    func unpairButtonDidTap() {
        self.unpairUserUseCase.unpair(user: self.user)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] _ in
                if let friendId = self?.user.friendId,
                   friendId != self?.user.id {
                    self?.firebaseMessageUseCase.sendMessage(to: friendId, message: PushMessageEntity.userDisconnected)
                }

                NotificationCenter.default.post(
                    name: AppCoordinator.Notifications.appRestartSignal,
                    object: nil
                )
            }
            .store(in: &self.cancellables)
    }
    
    func deinitRequested() {
        NotificationCenter.default.post(
            name: BaseCoordinator.Notifications.coordinatorRemoveFromParent,
            object: nil,
            userInfo: [BaseCoordinator.Keys.sceneId: self.sceneId]
        )
    }
}
