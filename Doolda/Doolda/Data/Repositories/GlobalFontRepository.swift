//
//  GlobalFontRepository.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/16.
//

import Foundation

final class GlobalFontRepository: GlobalFontRepositoryProtocol {
    private let userDefaultsPersistenceService: UserDefaultsPersistenceServiceProtocol
    
    init(persistenceService: UserDefaultsPersistenceServiceProtocol) {
        self.userDefaultsPersistenceService = persistenceService
    }
    
    func saveGlobalFont(as fontName: String) {
        self.userDefaultsPersistenceService.set(key: UserDefaults.Keys.globalFont, value: fontName)
    }
    
    func getGlobalFont() -> String? {
        guard let fontName: String = self.userDefaultsPersistenceService.get(key: UserDefaults.Keys.globalFont) else {
            return nil
        }
        return fontName
    }
}
