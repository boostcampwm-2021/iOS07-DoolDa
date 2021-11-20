//
//  StickerComponentEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import CoreGraphics
import Foundation

class StickerComponentEntity: ComponentEntity {
    var stickerName: String
    var stickerUrl: URL? {
        Bundle.main.url(forResource: self.stickerName, withExtension: "png")
    }

    private enum CodingKeys: String, CodingKey {
        case stickerName, type
    }
    
    init(frame: CGRect, scale: CGFloat, angle: CGFloat, aspectRatio: CGFloat, stickerName: String) {
        self.stickerName = stickerName
        super.init(frame: frame, scale: scale, angle: angle, aspectRatio: aspectRatio)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stickerName = try container.decode(String.self, forKey: .stickerName)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stickerName, forKey: .stickerName)
        try container.encode(ComponentType.sticker, forKey: .type)
    }
}
