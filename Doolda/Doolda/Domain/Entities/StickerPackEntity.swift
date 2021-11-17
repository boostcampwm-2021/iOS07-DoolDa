//
//  StickerPackEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import Foundation

enum StickerPackType: RawRepresentable, CaseIterable {
    typealias RawValue = StickerPackEntity?
    // FIXME: 나중에 삭제할 더미 데이터
    case dummy
    case color
    case buddy
    
    init?(rawValue: RawValue) {
        self = .color
    }
    
    var rawValue: RawValue {
        switch self {
        case .dummy: return StickerPackEntity.dummyStickerPack
        case .color: return StickerPackEntity.colorStickerPack
        case .buddy: return StickerPackEntity.buddyStickerPack
        }
    }
}

struct StickerPackEntity {
    let name: String
    var sealingImageUrl: URL
    var stickersUrl: [URL]
    var isUnpacked: Bool = false

    private let maximumStickerCount = 16
    
    init?(name: String) {
        self.name = name
        guard let coverUrl = Bundle.main.url(forResource: name + "_cover", withExtension: "png") else { return nil }
        self.sealingImageUrl = coverUrl
        self.stickersUrl = []
        for index in 0 ..< self.maximumStickerCount {
            guard let stickerUrl = Bundle.main.url(forResource: name + "_\(index)", withExtension: "png") else { break }
            self.stickersUrl.append(stickerUrl)
        }
        if self.stickersUrl.isEmpty { return nil }
    }

    static let dummyStickerPack = StickerPackEntity(name: "dummySticker")
    static let colorStickerPack = StickerPackEntity(name: "colorSticker")
    static let buddyStickerPack = StickerPackEntity(name: "buddySticker")
}
