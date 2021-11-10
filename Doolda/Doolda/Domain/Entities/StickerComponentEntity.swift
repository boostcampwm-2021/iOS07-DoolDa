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

    init(origin: CGPoint, size: CGSize, scale: CGFloat, angle: CGFloat, aspectRatio: CGFloat, name: String) {
        self.name = name
        super.init(origin: origin, size: size, scale: scale, angle: angle, aspectRatio: aspectRatio)
    }
}
