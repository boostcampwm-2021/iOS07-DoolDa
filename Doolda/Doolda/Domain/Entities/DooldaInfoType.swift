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
    case serviceAgreement
    case contributor

    var rawValue: String {
        switch self {
        case .appVersion:
            return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        case .openSourceLicense:
            return "오픈소스 라이센스"
        case .privacyPolicy:
            return "개인정보 처리방침"
        case .serviceAgreement:
            return "서비스 이용 약관"
        case .contributor:
            return "만든 사람들"
        }
    }
}

extension DooldaInfoType {
    var title: String {
        switch self {
        case .appVersion:
            return "앱 현재 버전"
        case .openSourceLicense:
            return "Open Source License"
        case .privacyPolicy:
            return "개인 정보 처리 방침"
        case .serviceAgreement:
            return "서비스 이용 약관"
        case .contributor:
            return "만든 사람들"
        }
    }

    var content: String {
        switch self {
        case .appVersion:
            return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        case .openSourceLicense:
            guard let path =  Bundle.main.path(forResource: "license", ofType: "txt"),
                  let text = try? String(contentsOfFile: path) else { return "" }
            return text
        case .privacyPolicy:
            guard let path =  Bundle.main.path(forResource: "privacyPolicy", ofType: "txt"),
                  let text = try? String(contentsOfFile: path) else { return "" }
            return text
        case .serviceAgreement:
            guard let path =  Bundle.main.path(forResource: "serviceAgreement", ofType: "txt"),
                  let text = try? String(contentsOfFile: path) else { return "" }
            return text
        case .contributor:
            return ""
        }
    }
}
