//
//  DoolDaFont.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/17.
//

import Foundation

enum FontType: CaseIterable {
    case dovemayo
    case darae
    case kotraHope
    case uhBeeMysen
    case dungGeunMo
    case kyoboHandwriting
    case appleNeo
}

extension FontType {
    var name: String {
        switch self {
        case.dovemayo:
            return "dovemayo"
        case.darae:
            return "drfont_daraehand"
        case .kotraHope:
            return "kotraHope"
        case .uhBeeMysen:
            return "uhBeeMysen"
        case .dungGeunMo:
            return "dungGeunMo"
        case .kyoboHandwriting:
            return "Kyobo Handwriting 2019"
        case .appleNeo:
            return "Apple SD Gothic Neo"
        }
    }

    var displayName: String {
        switch self {
        case .dovemayo:
            return "둘기 마요"
        case .darae:
            return "다래 손글씨체"
        case .kotraHope:
            return "코트라 희망체"
        case .uhBeeMysen:
            return "어비 마이센체"
        case .dungGeunMo:
            return "Neo 둥근모"
        case .kyoboHandwriting:
            return "교보 손글씨"
        case .appleNeo:
            return "애플 네오 고딕"
        }
    }
}
