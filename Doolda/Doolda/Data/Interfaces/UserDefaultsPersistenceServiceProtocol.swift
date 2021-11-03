//
//  UserDefaultsPersistenceServiceProtocol.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/03.
//

import Foundation

protocol UserDefaultsPersistenceServiceProtocol {
    func set(key: String, value: Any?)
    func get<T>(key: String) -> T?
    func remove(key: String)
}
