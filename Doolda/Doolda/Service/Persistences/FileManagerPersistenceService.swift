//
//  FileManagerPersistenceService.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/09.
//

import Combine
import Foundation

enum FileManagerPersistenceServiceError: LocalizedError {
    case failedToSaveFile
    case failedToFetchFile
    
    var errorDescription: String? {
        switch self {
        case .failedToSaveFile:
            return "파일 저장에 실패했습니다."
        case .failedToFetchFile:
            return "파일 불러오기에 실패했습니다."
        }
    }
}

class FileManagerPersistenceService: FileManagerPersistenceServiceProtocol {
    func save(data: Data, at documents: FileDocuments, fileName: String) -> AnyPublisher<URL, Error> {
        guard let fileUrl = documents.rawValue?.appendingPathComponent(fileName) else {
            return Fail(error: FileManagerPersistenceServiceError.failedToSaveFile).eraseToAnyPublisher()
        }
        
        let fileData = NSData(data: data)
        fileData.write(to: fileUrl, atomically: true)
        
        return Just(fileUrl).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func fetch(at documents: FileDocuments, fileName: String) -> AnyPublisher<Data, Error> {
        guard let fileUrl = documents.rawValue?.appendingPathComponent(fileName),
              let data = try? Data(contentsOf: fileUrl) else {
            return Fail(error: FileManagerPersistenceServiceError.failedToFetchFile).eraseToAnyPublisher()
        }
        
        return Just(data).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func fileExist(at documents: FileDocuments, fileName: String) -> Bool {
        guard let fileUrl = documents.rawValue?.appendingPathComponent(fileName) else {
            return false
        }
        
        return FileManager.default.fileExists(atPath: fileUrl.absoluteString)
    }
}
