//
//  CGFloat+Extensions.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/10.
//

import CoreGraphics

extension CGFloat {
    var degreeToRadian: CGFloat {
        return self * .pi / 180
    }
    
    var radianToDegree: CGFloat {
        return self * 180 / .pi
    }
}
