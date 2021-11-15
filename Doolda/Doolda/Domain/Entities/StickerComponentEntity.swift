//
//  StickerComponentEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import CoreGraphics
import Foundation

class StickerComponentEntity: ComponentEntity {
    var stickerUrl: URL

    private enum CodingKeys: String, CodingKey {
        case stickerUrl, type
    }
    
    init(frame: CGRect, scale: CGFloat, angle: CGFloat, aspectRatio: CGFloat, stickerUrl: URL) {
        self.stickerUrl = stickerUrl
        super.init(frame: frame, scale: scale, angle: angle, aspectRatio: aspectRatio)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stickerUrl = try container.decode(URL.self, forKey: .stickerUrl)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stickerUrl, forKey: .stickerUrl)
        try container.encode(ComponentType.sticker, forKey: .type)
    }
}
