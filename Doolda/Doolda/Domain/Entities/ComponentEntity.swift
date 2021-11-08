//
//  ComponentEntity.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/04.
//

import CoreGraphics
import Foundation

protocol ComponentEntity {
    var origin: CGPoint { get set }
    var size: CGSize { get set }
    var angle: CGFloat { get set }
}

extension ComponentEntity {
    func hitTest(at point: CGPoint) -> Bool {
        return false
    }
}

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
