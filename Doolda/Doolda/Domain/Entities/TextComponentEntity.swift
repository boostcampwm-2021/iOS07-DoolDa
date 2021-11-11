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
    
    init(frame: CGRect, scale: CGFloat, angle: CGFloat, aspectRatio: CGFloat, text: String, fontSize: CGFloat, fontColor: FontColorType) {
        self.text = text
        self.fontSize = fontSize
        self.fontColor = fontColor
        super.init(frame: frame, scale: scale, angle: angle, aspectRatio: aspectRatio)
    }
}
