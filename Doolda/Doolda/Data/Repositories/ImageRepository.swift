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
    private let firebaseNetworkService: FirebaseNetworkServiceProtocol

    init(fileManagerService: FileManagerPersistenceServiceProtocol, networkService: FirebaseNetworkServiceProtocol) {
        self.fileManagerPersistenceService = fileManagerService
        self.firebaseNetworkService = networkService
    }

    func saveLocal(imageData: Data, fileName: String) -> AnyPublisher<URL, Error> {
        return fileManagerPersistenceService.save(data: imageData, at: .temporary, fileName: fileName)
    }

    func saveRemote(user: User, imageData: Data, fileName: String) -> AnyPublisher<URL, Error> {
        guard let pairId = user.pairId else {
            return Fail(error: ImageRepositoryError.nilUserPairId).eraseToAnyPublisher()
        }
        return self.firebaseNetworkService.uploadData(path: pairId.ddidString, fileName: fileName, data: imageData)
    }
    
    func deleteRemote() {
        
    }

}
