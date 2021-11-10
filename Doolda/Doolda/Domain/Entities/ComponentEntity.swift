//
//  ComponentEntity.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/04.
//

import CoreGraphics
import Foundation

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

class ComponentEntity: ObservableObject {
    @Published var frame: CGRect
    @Published var scale: CGFloat
    @Published var angle: CGFloat
    @Published var aspectRatio: CGFloat
    
    var origin: CGPoint {
        get { self.frame.origin }
        set { self.frame.origin = newValue }
    }
    
    init(frame: CGRect, scale: CGFloat, angle: CGFloat, aspectRatio: CGFloat) {
        self.frame = frame
        self.scale = scale
        self.angle = angle
        self.aspectRatio = aspectRatio
    }
    
    // FIXME : 미구현상태
    func hitTest(at point: CGPoint) -> Bool {
        return false
    }
}

extension ComponentEntity: Hashable {
    static func == (lhs: ComponentEntity, rhs: ComponentEntity) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
