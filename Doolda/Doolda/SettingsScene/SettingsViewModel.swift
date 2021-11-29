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
    func disconnectButtonDidTap()
}

protocol SettingsViewModelOutput {
    var errorPublisher: Published<Error?>.Publisher { get }
    var pushNotificationStatePublisher: Published<Bool?>.Publisher { get }
    var selectedFontPublisher: Published<FontType?>.Publisher { get }
}

typealias SettingsViewModelProtocol = SettingsViewModelInput & SettingsViewModelOutput

class SettingsViewModel: SettingsViewModelProtocol {
    var errorPublisher: Published<Error?>.Publisher { self.$error }
    var pushNotificationStatePublisher: Published<Bool?>.Publisher { self.$isPushNotificationOn }
    var selectedFontPublisher: Published<FontType?>.Publisher { self.$selectedFont }

    private let user: User
    private let coordinator: SettingsViewCoordinatorProtocol
    private let globalFontUseCase: GlobalFontUseCaseProtocol
    private let pairUserUseCase: PairUserUseCaseProtocol
    private let pushNotificationStateUseCase: PushNotificationStateUseCaseProtocol
    private let firebaseMessageUseCase: FirebaseMessageUseCaseProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    @Published private var error: Error?
    @Published private var isPushNotificationOn: Bool?
    @Published private var selectedFont: FontType?

    init(
        user: User,
        coordinator: SettingsViewCoordinatorProtocol,
        globalFontUseCase: GlobalFontUseCaseProtocol,
        pairUserUseCase: PairUserUseCase,
        pushNotificationStateUseCase: PushNotificationStateUseCaseProtocol,
        firebaseMessageUseCase: FirebaseMessageUseCaseProtocol
    ) {
        self.user = user
        self.coordinator = coordinator
        self.globalFontUseCase = globalFontUseCase
        self.pairUserUseCase = pairUserUseCase
        self.pushNotificationStateUseCase = pushNotificationStateUseCase
        self.firebaseMessageUseCase = firebaseMessageUseCase
    }

    func settingsViewDidLoad() {
        self.isPushNotificationOn = self.pushNotificationStateUseCase.getPushNotificationState()
        self.selectedFont = self.globalFontUseCase.getGlobalFont()
    }

    func fontTypeDidTap() {
        self.coordinator.fontPickerSheetRequested()
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
        self.coordinator.settingsOptionRequested(
            title: "Open Source License",
            text: DooldaInfoType.openSourceLicense.rawValue
        )
    }

    func privacyPolicyDidTap() {
        self.coordinator.settingsOptionRequested(
            title: "개인 정보 처리 방침",
            text: DooldaInfoType.privacyPolicy.rawValue
        )
    }

    func contributorDidTap() {
        self.coordinator.settingsOptionRequested(
            title: "만든 사람들",
            text: DooldaInfoType.contributor.rawValue
        )
    }
    
    func disconnectButtonDidTap() {
        self.pairUserUseCase.disconnectPair(user: self.user)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] _ in
                if let friendId = self?.user.friendId,
                   friendId != self?.user.id {
                    self?.firebaseMessageUseCase.sendMessage(to: friendId, message: PushMessageEntity.userDisconnected)
                }
                self?.coordinator.splashViewRequested()
            }
            .store(in: &self.cancellables)
    }
}
