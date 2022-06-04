//
//  StorageReference+Extensions.swift
//  Doolda
//
//  Created by 정지승 on 2022/06/05.
//

import Combine
import Foundation

import Firebase

extension StorageReference {
    func delete() -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            self?.delete { error in
                if let error = error { return promise(.failure(error)) }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
}
