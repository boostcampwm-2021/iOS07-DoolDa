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
        let fileUrl = documents.rawValue.appendingPathComponent(fileName)
        let fileData = NSData(data: data)

        fileData.write(to: fileUrl, atomically: true)
        return Just(fileUrl).eraseToAnyPublisher()
    }    
}
