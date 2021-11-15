//
//  StickerPackEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import Foundation

struct StickerPackEntity {
    let name: String
    var stickersUrl: [URL]
    var isUnpacked: Bool = false
    
    init?(name: String) {
        self.name = name
        self.stickersUrl = []
        for index in 0 ... 15 {
            guard let stickerUrl = Bundle.main.url(forResource: name + "_\(index)", withExtension: "png") else { return nil }
            self.stickersUrl.append(stickerUrl)
        }
    }
    
    static let colorStickerPack = StickerPackEntity(name: "colorSticker")
    static let buddyStickerPack = StickerPackEntity(name: "buddySticker")
    
}
