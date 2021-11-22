//
//  TextInputViewModel.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/17.
//

import CoreGraphics
import Foundation

protocol TextEditViewModelProtocol {
    var selectedTextComponent: TextComponentEntity? { get }
    func inputViewEditingDidEnd(input: String, contentSize: CGSize, fontSize:CGFloat, color: FontColorType) -> TextComponentEntity
}

class TextEditViewModel: TextEditViewModelProtocol {
    private let textUseCase: TextUseCaseProtocol
    let selectedTextComponent: TextComponentEntity?
    
    init(textUseCase: TextUseCaseProtocol, selectedTextComponent: TextComponentEntity?) {
        self.textUseCase = textUseCase
        self.selectedTextComponent = selectedTextComponent
    }
    
    func inputViewEditingDidEnd(input: String, contentSize: CGSize, fontSize: CGFloat, color: FontColorType) -> TextComponentEntity {
        if let selectedTextComponent = selectedTextComponent {
            return self.textUseCase.changeTextComponent(
                from: selectedTextComponent,
                with: input,
                contentSize: contentSize,
                fontSize: fontSize,
                color: color
            )
        } else {
            return self.textUseCase.getTextComponent(with: input, contentSize: contentSize, fontSize: fontSize, color: color)
        }
    }
}
