//
//  StickerComponentEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import CoreGraphics
import Foundation

class StickerComponentEntity: ComponentEntity {
    var name: String

    private enum CodingKeys: String, CodingKey {
        case name
    }
    
    init(frame: CGRect, scale: CGFloat, angle: CGFloat, aspectRatio: CGFloat, name: String) {
        self.name = name
        super.init(frame: frame, scale: scale, angle: angle, aspectRatio: aspectRatio)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let superdecoder = try container.superDecoder()
        self.name = try container.decode(String.self, forKey: .name)
        try super.init(from: superdecoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
}
