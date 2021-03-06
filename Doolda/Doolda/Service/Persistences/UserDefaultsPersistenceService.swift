//
//  UserDefaultsPersistenceService.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/03.
//

import Foundation

final class UserDefaultsPersistenceService: UserDefaultsPersistenceServiceProtocol {
    
    static let shared: UserDefaultsPersistenceService = UserDefaultsPersistenceService()
    
    private init() {}
    
    func set(key: String, value: Any?) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func get<T>(key: String) -> T? {
        let value = UserDefaults.standard.object(forKey: key)
        return value as? T
    }
    
    func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
