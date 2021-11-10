//
//  FileManagerPersistenceServiceProtocol.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/09.
//

import Combine
import Foundation

protocol FileManagerPersistenceServiceProtocol {
    func save(data: Data, at documentsUrl: URL, fileName: String) -> AnyPublisher<Data, Error>
}
