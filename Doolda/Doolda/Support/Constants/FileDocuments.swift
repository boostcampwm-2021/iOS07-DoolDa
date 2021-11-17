//
//  FileDocuments.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/10.
//

import Foundation

enum FileDocuments {
    typealias RawValue = URL?

    case temporary
    case cache

    var rawValue: RawValue {
        switch self {
        case .temporary: return FileManager.default.temporaryDirectory
        case .cache: return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        }
    }
}
