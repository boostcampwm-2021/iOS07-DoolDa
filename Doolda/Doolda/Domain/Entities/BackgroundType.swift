//
//  BackgroundType.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/08.
//

import CoreGraphics
import Foundation

enum BackgroundType: CaseIterable {
    static var allCases: [BackgroundType] = [
        .plain(color: .dooldaBackground),
        .grid(color: .dooldaBackground),
        .lined(color: .dooldaBackground)
    ]
    
    case plain(color: CGColor?)
    case grid(color: CGColor?)
    case lined(color: CGColor?)
}
