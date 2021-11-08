//
//  PhotoFrameEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import CoreGraphics
import Foundation

// FIXME: Asset 이름을 String으로 갖고 있도록 구현
enum PhotoFrameType {}

struct PhotoFrameEntity {
    var frameAsset: PhotoFrameType
    var requiredPhotoCount: Int { photoBounds.count }
    let photoBounds: [CGRect]
}
