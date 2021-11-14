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
    case dooldaPink
    case dooldaBrown
    case dooldaPuple
    case dooldaGray
    case dooldaBlue
    
    var rawValue: RawValue {
        switch self {
        case .dooldaBackground: return #colorLiteral(red: 0.9607843137, green: 0.9411764706, blue: 0.9058823529, alpha: 1)
        case .dooldaPink: return #colorLiteral(red: 1, green: 0.957146585, blue: 0.9561807513, alpha: 1)
        case .dooldaBrown: return #colorLiteral(red: 0.8509803922, green: 0.8078431373, blue: 0.7450980392, alpha: 1)
        case .dooldaPuple: return #colorLiteral(red: 0.9137254902, green: 0.8666666667, blue: 0.937254902, alpha: 1)
        case .dooldaGray: return #colorLiteral(red: 0.8941176471, green: 0.8901960784, blue: 0.8901960784, alpha: 1)
        case .dooldaBlue: return #colorLiteral(red: 0.9019607843, green: 0.9176470588, blue: 0.9411764706, alpha: 1)
        }
    }
}
