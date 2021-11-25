//
//  SettingsViewCoordinatorProtocol.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/21.
//

import Foundation

protocol SettingsViewCoordinatorProtocol {
    func fontPickerSheetRequested()
    func settingsOptionRequested(title: String, text: String)
    func splashViewRequested()
}
