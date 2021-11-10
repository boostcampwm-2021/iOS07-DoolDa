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

    init(frame: CGRect, scale: CGFloat, angle: CGFloat, aspectRatio: CGFloat, imageUrl: URL) {
        self.imageUrl = imageUrl
        super.init(frame: frame, scale: scale, angle: angle, aspectRatio: aspectRatio)
    }
}
