//
//  PhotoComponentEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import CoreGraphics
import Foundation

class PhotoComponentEntity: ComponentEntity {
    var imageUrl: URL

    init(origin: CGPoint, size: CGSize, angle: CGFloat, aspectRatio: CGFloat, imageUrl: URL) {
        self.imageUrl = imageUrl
        super.init(origin: origin, size: size, angle: angle, aspectRatio: aspectRatio)
    }
}
