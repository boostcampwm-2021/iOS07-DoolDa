//
//  FontColorType.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/09.
//

import CoreGraphics
import Foundation

enum FontColorType: RawRepresentable, CaseIterable, Codable {
    typealias RawValue = CGColor
    
    case black
    case dooldaLabel
    
    init(rawValue: RawValue) {
        self = .dooldaLabel
    }
    
    var rawValue: RawValue {
        switch self {
        case .black: return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .dooldaLabel: return #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.3490196078, alpha: 1)
        }
    }
}
