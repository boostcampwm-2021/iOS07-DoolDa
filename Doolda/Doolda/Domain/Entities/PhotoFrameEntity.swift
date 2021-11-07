//
//  PhotoFrameEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import Foundation
import CoreGraphics

struct PhotoFrameEntity {
    var frameUrl: URL
    var requiredPhotoCount: Int { photoBounds.count }
    let photoBounds: [CGRect]
}
