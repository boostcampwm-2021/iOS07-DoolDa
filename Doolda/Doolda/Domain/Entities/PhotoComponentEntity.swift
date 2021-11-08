//
//  PhotoComponentEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import Foundation
import CoreGraphics

struct PhotoComponentEntity: ComponentEntity {
    let aspectRatio: CGFloat // width / height

    var origin: CGPoint
    var size: CGSize
    var angle: CGFloat {
        get { return wrappedAngle }
        set { self.wrappedAngle = newValue }
    }
    var imageUrl: URL

    @Angle private var wrappedAngle: CGFloat

    init(origin: CGPoint, size: CGSize, angle: CGFloat, aspectRatio: CGFloat, imageUrl: URL) {
        self.origin = origin
        self.size = size
        self.wrappedAngle = angle
        self.aspectRatio = aspectRatio
        self.imageUrl = imageUrl
    }

    // FIXME: - 내부 구현 필요
    func hitTest(at point: CGPoint) -> Bool {
        return false
    }
}
