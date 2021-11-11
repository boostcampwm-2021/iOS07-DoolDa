//
//  BackgroundType.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/08.
//

import CoreGraphics
import Foundation

enum BackgroundType: CaseIterable, Codable {
    typealias RawValue = CGColor
    
    case dooldaBackground
    
    init(rawValue: RawValue) {
        self = .dooldaBackground
    }
    
    var rawValue: RawValue {
        switch self {
        case .dooldaBackground: return #colorLiteral(red: 0.9607843137, green: 0.9411764706, blue: 0.9058823529, alpha: 1)
        }
    }
}
