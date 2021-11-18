//
//  TextUseCase.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/18.
//

import CoreGraphics
import Foundation

protocol TextUseCaseProtocol {
    func getTextComponent(with input: String, contentSize: CGSize, fontSize:CGFloat, color: FontColorType) -> TextComponentEntity
}

class TextUseCase: TextUseCaseProtocol {
    func getTextComponent(with input: String, contentSize: CGSize, fontSize: CGFloat, color: FontColorType) -> TextComponentEntity {
        let componentOrigin = CGPoint(x: 850 - contentSize.width/2, y: 1500 - contentSize.height/2)
        return TextComponentEntity(
            frame: CGRect(origin: componentOrigin, size: contentSize),
            scale: 1.0,
            angle: 0,
            aspectRatio: 1,
            text: input,
            fontSize: fontSize,
            fontColor: color
        )
    }
}
