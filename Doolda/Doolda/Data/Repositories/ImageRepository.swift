//
//  ImageRepository.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/10.
//

import Combine
import Foundation

class ImageRepository: ImageRepositoryProtocol {
    private let fileManagerPersistenceService: FileManagerPersistenceServiceProtocol
    private let urlSessionNetworkService: URLSessionNetworkServiceProtocol

    init(fileManagerService: FileManagerPersistenceServiceProtocol, networkService: URLSessionNetworkServiceProtocol) {
        self.fileManagerPersistenceService = fileManagerService
        self.urlSessionNetworkService = networkService
    }

    func saveLocal(imageData: Data, fileName: String) -> AnyPublisher<URL, Never> {
        
        return Just(URL(string: "")!).eraseToAnyPublisher()
    }

    func saveRemote(user: User, imageData: Data, fileName: String) -> AnyPublisher<URL, Error> {
        return Just(URL(string: "")!).tryMap{ $0 }.eraseToAnyPublisher()
    }

}
