//
//  Collection+Extensions.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/22.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    subscript (exist index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
