//
//  StickerPackEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import Foundation

enum StickerPackType: RawRepresentable, CaseIterable {
    typealias RawValue = StickerPackEntity?

    case htmlCoder
    case boolbada
    case buddy
    
    init?(rawValue: RawValue) {
        self = .boolbada
    }
    
    var rawValue: RawValue {
        switch self {
        case .htmlCoder: return StickerPackEntity.htmlCoderStickerPack
        case .boolbada: return StickerPackEntity.boolbadaStickerPack
        case .buddy: return StickerPackEntity.buddyStickerPack
        }
    }
}

class StickerPackEntity {
    let displayName: String
    let familyName: String
    let stickerCount: Int

    var isUnpacked: Bool = false
    var coverStickerName: String { self.familyName + "_cover" }
    var stickersName: [String] {
        (0..<self.stickerCount).map { number in
            self.familyName + "_\(number)"
        }
    }

    init(displayName: String, familyName: String, stickerCount: Int) {
        self.displayName = displayName
        self.familyName = familyName
        self.stickerCount = stickerCount
    }

    static let htmlCoderStickerPack = StickerPackEntity(
        displayName: "저는 HTML로 코딩해요",
        familyName: "htmlCoder",
        stickerCount: 11
    )
    static let boolbadaStickerPack = StickerPackEntity(
        displayName: "불타는 불바다",
        familyName: "boolbada",
        stickerCount: 8
    )
    static let buddyStickerPack = StickerPackEntity(
        displayName: "위드버디",
        familyName: "withBuddy",
        stickerCount: 12
    )
}
