//
//  RawPageEntity.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/04.
//

import CoreGraphics
import Foundation

struct RawPageEntity: Codable {
    var components: [ComponentEntity]
    var backgroundType: BackgroundType
    
    init() {
        self.components = []
        self.backgroundType = .dooldaBackground
    }
    
    mutating func append(component: ComponentEntity) {
        self.components.append(component)
    }
    
    mutating func remove(at index: Int) {
        self.components.remove(at: index)
    }
    
    func indexOf(component: ComponentEntity) -> Int? {
        return self.components.firstIndex(of: component)
    }
}
