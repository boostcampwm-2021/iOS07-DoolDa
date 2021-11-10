//
//  TextComponentEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import CoreGraphics
import Foundation

class TextComponentEntity: ComponentEntity {
    @Published var text: String
    @Published var fontSize: CGFloat
    @Published var fontColor: FontColorType
    
    init(origin: CGPoint, size: CGSize, scale: CGFloat, angle: CGFloat, aspectRatio: CGFloat, text: String, fontSize: CGFloat, fontColor: FontColorType) {
        self.text = text
        self.fontSize = fontSize
        self.fontColor = fontColor
        super.init(origin: origin, size: size, scale: scale, angle: angle, aspectRatio: aspectRatio)
    }
}
