//
//  GlobalFontRepositoryProtocol.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/16.
//

import Foundation

protocol GlobalFontRepositoryProtocol {
    func setGlobalFont(_ fontName: String)
    func getGlobalFont() -> String?
}
