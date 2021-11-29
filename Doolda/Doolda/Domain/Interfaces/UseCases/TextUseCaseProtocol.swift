//
//  TextUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import CoreGraphics
import Foundation

protocol TextUseCaseProtocol {
    func changeTextComponent(from textComponent: TextComponentEntity, with input: String, contentSize: CGSize, fontSize:CGFloat, color: FontColorType) -> TextComponentEntity
    func getTextComponent(with input: String, contentSize: CGSize, fontSize:CGFloat, color: FontColorType) -> TextComponentEntity
}
