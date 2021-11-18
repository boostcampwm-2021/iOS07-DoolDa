//
//  TextUseCase.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/18.
//

import CoreGraphics
import Foundation

protocol TextUseCaseProtocol {
    func getTextComponent(with input: NSAttributedString, size:CGFloat, color: FontColorType) -> TextComponentEntity
}

class TextUseCase: TextUseCaseProtocol {
    func getTextComponent(with input: NSAttributedString, size: CGFloat, color: FontColorType) -> TextComponentEntity {
        let textSize = input.size()
        let componentOrigin = CGPoint(x: 850 - textSize.width/2, y: 1500 - textSize.height/2)
        return TextComponentEntity(
            frame: CGRect(origin: componentOrigin, size: textSize),
            scale: 1.0,
            angle: 0,
            aspectRatio: 1,
            text: input.string,
            fontSize: size,
            fontColor: color
        )
    }
}
