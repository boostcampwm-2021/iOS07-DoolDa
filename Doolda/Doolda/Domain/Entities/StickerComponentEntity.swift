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

    init(frame: CGRect, scale: CGFloat, angle: CGFloat, aspectRatio: CGFloat, name: String) {
        self.name = name
        super.init(frame: frame, scale: scale, angle: angle, aspectRatio: aspectRatio)
    }
}
