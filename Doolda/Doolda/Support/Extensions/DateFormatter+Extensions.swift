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
    
    static let firestoreFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
    
    static let monthNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()
    
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter
    }()
    
    static let koreanFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.dateFormat = "yyyy.M.dd.eeee"
        return formatter
    }()
}
