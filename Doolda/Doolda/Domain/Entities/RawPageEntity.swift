//
//  RawPageEntity.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/04.
//

import CoreGraphics
import Foundation

typealias BackgroundType = CGColor

struct RawPageEntity {
    var components: [ComponentEntity]
    var backgroundType: BackgroundType

    mutating func append(_ component: ComponentEntity) {
        components.append(component)
    }
}
