//
//  ComponentEntity.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/04.
//

import CoreGraphics
import Foundation

class ComponentEntity: Codable {
    var frame: CGRect
    var scale: CGFloat
    var angle: CGFloat
    var aspectRatio: CGFloat
    
    enum CodingKeys: String, CodingKey {
        case frame, scale, angle, aspectRatio
    }
    
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
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.frame = try container.decode(CGRect.self, forKey: .frame)
        self.scale = try container.decode(CGFloat.self, forKey: .scale)
        self.angle = try container.decode(CGFloat.self, forKey: .angle)
        self.aspectRatio = try container.decode(CGFloat.self, forKey: .aspectRatio)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(frame, forKey: .frame)
        try container.encode(scale, forKey: .scale)
        try container.encode(angle, forKey: .angle)
        try container.encode(aspectRatio, forKey: .aspectRatio)
    }
    
    func hitTest(at point: CGPoint) -> Bool {
        let centerX = frame.origin.x + frame.size.width / 2
        let centerY = frame.origin.y + frame.size.height / 2
        
        let zeroCentered = CGPoint(x: point.x - centerX, y: point.y - centerY)
        var transform = CGAffineTransform.identity
        transform = transform.rotated(by: self.angle)
        transform = transform.scaledBy(x: scale, y: scale)
        transform = transform.inverted()
        
        let reversed = zeroCentered.applying(transform)
        let adjustedPoint = CGPoint(x: reversed.x + centerX, y: reversed.y + centerY)
        
        return self.frame.contains(adjustedPoint)
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
