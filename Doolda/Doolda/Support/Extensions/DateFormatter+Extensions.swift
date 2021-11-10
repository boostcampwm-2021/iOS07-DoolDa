//
//  DateFormatter+Extensions.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/10.
//

import Foundation

extension DateFormatter {
    static let jsonPathFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYMMddHHmmss"
        return formatter
    }()
}
