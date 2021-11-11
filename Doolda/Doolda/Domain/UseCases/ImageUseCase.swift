//
//  ImageUseCase.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/09.
//

import Combine
import CoreImage
import Foundation

protocol ImageUseCaseProtocol {
    func saveLocal(image: CIImage) -> AnyPublisher<URL, Never>
    func saveRemote(for user: User, localUrl: URL) -> AnyPublisher<URL, Error>
}

class ImageUseCase: ImageUseCaseProtocol {
    private let imageRepository: ImageRepositoryProtocol

    init(imageRepository: ImageRepositoryProtocol) {
        self.imageRepository = imageRepository
    }

    func saveLocal(image: CIImage) -> AnyPublisher<URL, Never> {
        // image를 data로 변환
        // fileName을 UUID로 생성
        return imageRepository.saveLocal(imageData: Data(), fileName: "")
    }

    func saveRemote(for user: User, localUrl: URL) -> AnyPublisher<URL, Error> {
        // localUrl에서 data로 변환
        // UUID로 파일이름 생성 ㅎㅎ
        return imageRepository.saveRemote(user: User(id: DDID(), pairId: DDID()), imageData: Data(), fileName: "")
    }
}
