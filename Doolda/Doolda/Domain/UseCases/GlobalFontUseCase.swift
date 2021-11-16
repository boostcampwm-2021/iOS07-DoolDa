//
//  GlobalFontUseCase.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/16.
//

import Foundation
import UIKit

protocol GlobalFontUseCaseProtocol {
    func setGlobalFont(with fontName: String)
    func saveGlobalFont(as fontName: String)
    func getGlobalFont() -> String?
}

class GlobalFontUseCase: GlobalFontUseCaseProtocol {
    private let globalFontRepository: GlobalFontRepositoryProtocol

    init(globalFontRepository: GlobalFontRepositoryProtocol) {
        self.globalFontRepository = globalFontRepository
    }

    func setGlobalFont(with fontName: String) {
        UIFont.globalFontFamily = fontName
    }
    
    func saveGlobalFont(as fontName: String) {
        self.globalFontRepository.saveGlobalFont(as: fontName)
    }
    
    func getGlobalFont() -> String? {
        return self.globalFontRepository.getGlobalFont()
    }
}
