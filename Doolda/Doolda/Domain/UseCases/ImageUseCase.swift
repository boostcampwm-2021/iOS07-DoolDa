//
//  ImageUseCase.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/09.
//

import Combine
import CoreImage
import Foundation

enum ImageUseCaseError: LocalizedError {
    case nilImageData
    case failToLoadImageFromUrl

    var errorDescription: String? {
        switch self {
        case .nilImageData:
            return "이미지 데이터 변환에 실패하였습니다."
        case .failToLoadImageFromUrl:
            return "잘못된 이미지 url 입니다."
        }
    }
}

protocol ImageUseCaseProtocol {
    func saveLocal(image: CIImage) -> AnyPublisher<URL, Error>
    func saveRemote(for user: User, localUrl: URL) -> AnyPublisher<URL, Error>
}

class ImageUseCase: ImageUseCaseProtocol {
    private let imageRepository: ImageRepositoryProtocol

    init(imageRepository: ImageRepositoryProtocol) {
        self.imageRepository = imageRepository
    }

    func saveLocal(image: CIImage) -> AnyPublisher<URL, Error> {
        guard let imageData = image.data else {
            return Fail(error: ImageUseCaseError.nilImageData).eraseToAnyPublisher()
        }
        let imageName = UUID().uuidString
        return imageRepository.saveLocal(imageData: imageData, fileName: imageName)
    }

    func saveRemote(for user: User, localUrl: URL) -> AnyPublisher<URL, Error> {
        guard let imageData = try? Data(contentsOf: localUrl) else {
            return Fail(error: ImageUseCaseError.failToLoadImageFromUrl).eraseToAnyPublisher()
        }
        let imageName = UUID().uuidString
        return imageRepository.saveRemote(user: user, imageData: imageData, fileName: imageName)
    }
}
