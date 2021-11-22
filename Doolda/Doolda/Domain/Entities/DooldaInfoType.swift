//
//  DooldaInfoType.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/22.
//

import Foundation

enum DooldaInfoType: String {
    case appVersion
    case openSourceLicense
    case privacyPolicy
    case contributor

    var rawValue: String {
        switch self {
        case .appVersion:
            return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        case .openSourceLicense:
            return "오픈소스 라이센스"
        case .privacyPolicy:
            return "개인정보 처리방침"
        case .contributor:
            return "만든 사람들"
        }
    }
}
