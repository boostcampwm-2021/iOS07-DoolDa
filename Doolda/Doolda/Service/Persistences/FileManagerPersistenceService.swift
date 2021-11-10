//
//  FileManagerPersistenceService.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/09.
//

import Combine
import Foundation

class FileManagerPersistenceService: FileManagerPersistenceServiceProtocol {
    func save(data: Data, at documents: FileDocuments, fileName: String) -> AnyPublisher<URL, Never> {
        let fileManager = FileManager.default
        let fileUrl = documents.rawValue.appendingPathComponent(fileName)
        let fileData = NSData(data: data)

        fileData.write(to: fileUrl, atomically: true)

        do {
            try fileData.write(to: fileUrl, atomically: true)
        } catch let error {
            return Fail(error: error).eraseToAnyPublisher()
        }

        return Just(fileUrl).eraseToAnyPublisher()
    }    
}
