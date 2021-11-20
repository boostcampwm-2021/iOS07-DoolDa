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

    var coverSticker: String { familyName + "_cover" }
    var stickers: [String] {
        (0..<stickerCount).map { number in
            familyName + "_\(number)"
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
        displayName: "불바다 팩",
        familyName: "boolbadaSticker",
        stickerCount: 5
    )
    static let buddyStickerPack = StickerPackEntity(
        displayName: "동글이 팩",
        familyName: "buddySticker",
        stickerCount: 5
    )
}
