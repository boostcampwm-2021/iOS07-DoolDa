//
//  GlobalFontRepositoryProtocol.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/16.
//

import Foundation

protocol GlobalFontRepositoryProtocol {
    func saveGlobalFont(as fontName: String)
    func getGlobalFont() -> String?
}
