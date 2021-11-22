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
    var selectedFontPublisher: Published<String>.Publisher { get }
}

typealias SettingsViewModelProtocol = SettingsViewModelInput & SettingsViewModelOutput

class SettingsViewModel: SettingsViewModelProtocol {
    var selectedFontPublisher: Published<String>.Publisher { self.$selectedFont }

    @Published private var selectedFont: String

    func fontTypeDidChanged(_ fontName: String) {
        <#code#>
    }

    func pushNotificationDidToggle() {
        <#code#>
    }

    func openSourceLicenseDidTap() {
        <#code#>
    }

    func privacyPolicyDidTap() {
        <#code#>
    }

    func contributorDidTap() {
        <#code#>
    }
}
