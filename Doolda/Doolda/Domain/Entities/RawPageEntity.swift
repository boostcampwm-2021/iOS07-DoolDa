//
//  RawPageEntity.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/04.
//

import Foundation
import CoreGraphics

typealias BackgroundType = CGColor

struct RawPageEntity {
    var components: [ComponentEntity]
    var backgroundType: BackgroundType
}
