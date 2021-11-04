//
//  ComponentEntity.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/04.
//

import Foundation
import CoreGraphics

@propertyWrapper
struct Angle {
    private var value: CGFloat = CGFloat.zero
    
    var wrappedValue: CGFloat {
        get { self.value }
        set { self.value = newValue.truncatingRemainder(dividingBy: 360) }
    }
    
    init(wrappedValue initalValue: CGFloat) {
        self.wrappedValue = initalValue
    }
}

struct ComponentEntity {
    var origin: CGPoint
    var size: CGSize
    @Angle var angle: CGFloat

    func hitTest(at point: CGPoint) -> Bool { return false }
}
