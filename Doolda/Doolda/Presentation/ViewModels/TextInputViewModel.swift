//
//  TextInputViewModel.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/17.
//

import CoreGraphics
import Foundation

protocol TextInputViewModelProtocol {
    func inputViewEditingDidEnd(input: NSAttributedString, size:CGFloat, color: FontColorType) -> TextComponentEntity
}

class TextInputViewModel {
    private let textUseCase: TextUseCaseProtocol
    
    init(textUseCase: TextUseCaseProtocol) {
        self.textUseCase = textUseCase
    }

    func inputViewEditingDidEnd(input: NSAttributedString, size:CGFloat, color: FontColorType) -> TextComponentEntity {
        return self.textUseCase.getTextComponent(with: input, size: size, color: color)
    }
}
