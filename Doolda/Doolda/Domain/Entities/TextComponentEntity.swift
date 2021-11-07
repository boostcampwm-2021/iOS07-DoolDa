//
//  TextComponentEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import Foundation
import CoreGraphics

struct TextComponentEntity: ComponentEntity {
    enum Color {

    }

    var origin: CGPoint
    var size: CGSize
    var angle: CGFloat
    var text: String
    var fontSize: CGFloat
    var fontColor: Color

    func hitTest(at point: CGPoint) -> Bool {
        return false
    }

}
