//
//  DummyGlobalFontRepository.swift
//  GlobalFontUseCaseTest
//
//  Created by 김민주 on 2021/11/30.
//

import Foundation

class DummyGlobalFontRepository: GlobalFontRepositoryProtocol {
    var dummyGlobalFontName: String?
    
    init(dummyGlobalFontName: String? = nil) {
        self.dummyGlobalFontName = dummyGlobalFontName
    }
    
    func saveGlobalFont(as fontName: String) {
        self.dummyGlobalFontName = fontName
    }
    
    func getGlobalFont() -> String? {
        return self.dummyGlobalFontName
    }
}
