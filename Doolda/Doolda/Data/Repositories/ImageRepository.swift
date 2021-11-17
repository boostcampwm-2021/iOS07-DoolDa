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
    case nilRemoteUrl

    var errorDescription: String? {
        switch self {
        case .nilUserPairId:
            return "유저의 페어 아이디가 존재하지 않습니다."
        case .nilRemoteUrl:
            return "잘못된 remote url 입니다."
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

    func saveLocal(imageData: Data, fileName: String) -> AnyPublisher<URL, Error> {
        return fileManagerPersistenceService.save(data: imageData, at: .temporary, fileName: fileName)
    }

    func saveRemote(user: User, imageData: Data, fileName: String) -> AnyPublisher<URL, Error> {
        guard let pairId = user.pairId else {
            return Fail(error: ImageRepositoryError.nilUserPairId).eraseToAnyPublisher()
        }
        let urlRequest = FirebaseAPIs.uploadDataFile(pairId.ddidString, fileName, imageData)
        let publisher: AnyPublisher<[String:String], Error> = self.urlSessionNetworkService.request(urlRequest)

        return publisher.tryMap { _ -> URL in
            guard let remoteUrl = FirebaseAPIs.downloadDataFile(pairId.ddidString, fileName).urlRequest?.url else {
                throw ImageRepositoryError.nilRemoteUrl
            }
            return remoteUrl
        }
        .eraseToAnyPublisher()
    }

}
