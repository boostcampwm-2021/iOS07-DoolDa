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
    case blue
    case green
    case yellow
    case orange
    case red
    case purple
    
    init(rawValue: RawValue) {
        self = .dooldaLabel
    }
    
    var rawValue: RawValue {
        switch self {
        case .black: return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .dooldaLabel: return #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.3490196078, alpha: 1)
        case .blue: return #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        case .green: return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        case .yellow: return #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        case .orange: return #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        case .red: return #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        case .purple: return #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        }
    }
}
