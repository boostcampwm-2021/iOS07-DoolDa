//
//  StickerPackEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import CoreGraphics
import Foundation

struct StickerPackEntity {
    let name: String
    let packedImageName: String
    let stickers: [String]
    var isUnpacked: Bool = false
}
