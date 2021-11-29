//
//  GlobalFontUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import UIKit

protocol GlobalFontUseCaseProtocol {
    func setGlobalFont(with fontName: String)
    func saveGlobalFont(as fontName: String)
    func getGlobalFont() -> FontType?
}
