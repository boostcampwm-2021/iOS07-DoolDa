//
//  TextComponentEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import CoreGraphics
import Foundation

class TextComponentEntity: ComponentEntity {
    var text: String
    var fontSize: CGFloat
    var fontColor: FontColorType
    
    private enum CodingKeys: String, CodingKey {
        case text, fontSize, fontColor, type
    }
    
    init(frame: CGRect, scale: CGFloat, angle: CGFloat, aspectRatio: CGFloat, text: String, fontSize: CGFloat, fontColor: FontColorType) {
        self.text = text
        self.fontSize = fontSize
        self.fontColor = fontColor
        super.init(frame: frame, scale: scale, angle: angle, aspectRatio: aspectRatio)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.fontSize = try container.decode(CGFloat.self, forKey: .fontSize)
        self.fontColor = try container.decode(FontColorType.self, forKey: .fontColor)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encode(fontColor, forKey: .fontColor)
        try container.encode(ComponentType.text, forKey: .type)
    }
}
