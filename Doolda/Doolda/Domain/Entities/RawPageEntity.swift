//
//  RawPageEntity.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/04.
//

import CoreGraphics
import Foundation

struct RawPageEntity {
    var components: [ComponentEntity]
    var backgroundColor: BackgroundType
    
    init() {
        self.components = []
        self.backgroundType = .dooldaBackground
    }
    
    mutating func append(component: ComponentEntity) {
        self.components.append(component)
    }
}
