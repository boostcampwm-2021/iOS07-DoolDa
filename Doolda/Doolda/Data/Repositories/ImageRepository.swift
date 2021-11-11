//
//  ImageRepository.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/10.
//

import Combine
import Foundation

enum ImageRepositoryError: LocalizedError {
    case nilUserPairId

    var errorDescription: String? {
        switch self {
        case.nilUserPairId:
            return "유저의 페어 아이디가 존재하지 않습니다."
        }
    }
}

class ImageRepository: ImageRepositoryProtocol {
    private let fileManagerPersistenceService: FileManagerPersistenceServiceProtocol
    private let urlSessionNetworkService: URLSessionNetworkServiceProtocol

    init(fileManagerService: FileManagerPersistenceServiceProtocol, networkService: URLSessionNetworkServiceProtocol) {
        self.fileManagerPersistenceService = fileManagerService
        self.urlSessionNetworkService = networkService
    }

    func saveLocal(imageData: Data, fileName: String) -> AnyPublisher<URL, Never> {
        return fileManagerPersistenceService.save(data: imageData, at: .temporary, fileName: fileName)
    }

    func saveRemote(user: User, imageData: Data, fileName: String) -> AnyPublisher<URL, Error> {
        guard let pairId = user.pairId else {
            return Fail(error: ).eraseToAnyPublisher()
        }
        let urlRequest = FirebaseAPIs.createStorageFile(<#T##String#>, <#T##String#>, <#T##Data#>)
        return Just(URL(string: "")!).tryMap{ $0 }.eraseToAnyPublisher()
    }

}
