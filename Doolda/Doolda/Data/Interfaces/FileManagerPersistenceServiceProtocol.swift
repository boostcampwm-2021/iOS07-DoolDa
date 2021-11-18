//
//  FileManagerPersistenceServiceProtocol.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/09.
//

import Combine
import Foundation

protocol FileManagerPersistenceServiceProtocol {
    func save(data: Data, at documents: FileDocuments, fileName: String) -> AnyPublisher<URL, Error>
    func fetch(at documents: FileDocuments, fileName: String) -> AnyPublisher<Data, Error>
    func isFileExists(at documents: FileDocuments, fileName: String) -> Bool
}
