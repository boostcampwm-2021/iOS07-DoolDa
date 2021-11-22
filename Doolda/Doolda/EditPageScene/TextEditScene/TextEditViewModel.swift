//
//  TextInputViewModel.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/17.
//

import CoreGraphics
import Foundation

protocol TextEditViewModelProtocol {
    func inputViewEditingDidEnd(input: String, contentSize: CGSize, fontSize:CGFloat, color: FontColorType) -> TextComponentEntity
}

class TextEditViewModel: TextEditViewModelProtocol {
    private let textUseCase: TextUseCaseProtocol
    private let selectedTextComponent: TextComponentEntity?
    
    init(textUseCase: TextUseCaseProtocol, selectedTextComponent: TextComponentEntity?) {
        self.textUseCase = textUseCase
        self.selectedTextComponent = selectedTextComponent
    }
    
    func inputViewEditingDidEnd(input: String, contentSize: CGSize, fontSize: CGFloat, color: FontColorType) -> TextComponentEntity {
        return self.textUseCase.getTextComponent(with: input, contentSize: contentSize, fontSize: fontSize, color: color)
    }
}
