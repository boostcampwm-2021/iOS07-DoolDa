//
//  SettingsViewModel.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/22.
//

import Combine
import Foundation

protocol SettingsViewModelInput {
    func fontTypeDidChanged(_ fontName: String)
    func pushNotificationDidToggle()
    func openSourceLicenseDidTap()
    func privacyPolicyDidTap()
    func contributorDidTap()
}

protocol SettingsViewModelOutput {
    var selectedFontPublisher: Published<String?>.Publisher { get }
}

typealias SettingsViewModelProtocol = SettingsViewModelInput & SettingsViewModelOutput

class SettingsViewModel: SettingsViewModelProtocol {
    var selectedFontPublisher: Published<String?>.Publisher { self.$selectedFont }

    private let coordinator: SettingsViewCoordinatorProtocol
    private let globalFontUseCase: GlobalFontUseCaseProtocol
    private let pushNotificationStateUseCase: PushNotificationStateUseCaseProtocol
    private var cancellables: Set<AnyCancellable> = []
    @Published private var selectedFont: String?

    init(
        coordinator: SettingsViewCoordinatorProtocol,
        globalFontUseCase: GlobalFontUseCaseProtocol,
        pushNotificationStateUseCase: PushNotificationStateUseCaseProtocol
    ) {
        self.coordinator = coordinator
        self.globalFontUseCase = globalFontUseCase
        self.pushNotificationStateUseCase = pushNotificationStateUseCase
        self.selectedFont = self.globalFontUseCase.getGlobalFont()
    }

    func fontTypeDidChanged(_ fontName: String) {

    }

    func pushNotificationDidToggle() {

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

}
