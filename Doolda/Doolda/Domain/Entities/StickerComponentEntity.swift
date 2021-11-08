//
//  StickerComponentEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import CoreGraphics
import Foundation

struct StickerComponentEntity: ComponentEntity {
    let aspectRatio: CGFloat

    var origin: CGPoint
    var size: CGSize
    var name: String
    @Angle var angle: CGFloat

    init(origin: CGPoint, size: CGSize, angle: CGFloat, aspectRatio: CGFloat, name: String) {
        self.origin = origin
        self.size = size
        self.angle = angle
        self.aspectRatio = aspectRatio
        self.name = name
    }

}
