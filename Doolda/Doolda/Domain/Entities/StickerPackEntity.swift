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

    static let htmlCoderStickerPack = StickerPackEntity(name: "htmlCoder")
    static let boolbadaStickerPack = StickerPackEntity(name: "boolbadaSticker")
    static let buddyStickerPack = StickerPackEntity(name: "buddySticker")
}
