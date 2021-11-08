//
//  PhotoComponentEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import CoreGraphics
import Foundation

struct PhotoComponentEntity: ComponentEntity {
    let aspectRatio: CGFloat // width / height

    var origin: CGPoint
    var size: CGSize
    @Angle var angle: CGFloat

    var imageUrl: URL

    init(origin: CGPoint, size: CGSize, angle: CGFloat, aspectRatio: CGFloat, imageUrl: URL) {
        self.origin = origin
        self.size = size
        self.angle = angle
        self.aspectRatio = aspectRatio
        self.imageUrl = imageUrl
    }

}
