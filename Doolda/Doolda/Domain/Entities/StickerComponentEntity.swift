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
    @Angle var angle: CGFloat
//    var angle: CGFloat {
//        get { return wrappedAngle }
//        set { self.wrappedAngle = newValue }
//    }
    var name: String

    @Angle private var wrappedAngle: CGFloat

    init(origin: CGPoint, size: CGSize, angle: CGFloat, aspectRatio: CGFloat, name: String) {
        self.origin = origin
        self.size = size
        self.wrappedAngle = angle
        self.aspectRatio = aspectRatio
        self.name = name
    }

    func hitTest(at point: CGPoint) -> Bool {
        return false
    }

}
