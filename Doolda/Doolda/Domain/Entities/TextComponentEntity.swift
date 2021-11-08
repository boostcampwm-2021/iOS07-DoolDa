//
//  TextComponentEntity.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/07.
//

import Foundation
import CoreGraphics

enum FontColorType { }

struct TextComponentEntity: ComponentEntity {
    var origin: CGPoint
    var size: CGSize
    var angle: CGFloat
    var text: String
    var fontSize: CGFloat
    var fontColor: FontColorType

    func hitTest(at point: CGPoint) -> Bool {
        return false
    }

}
