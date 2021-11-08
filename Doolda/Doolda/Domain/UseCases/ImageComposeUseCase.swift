//
//  ImageComposeUseCase.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/08.
//

import Combine
import CoreImage
import Foundation

enum ImageComposeUseCaseError: LocalizedError {
    case numberOfImageMismatched
}

protocol ImageComposeUseCaseProtocol {
    func compose(photoFrame: CIImage, photoBounds: [CGRect], images: [CIImage]) -> AnyPublisher<CIImage, Error>
}

class ImageComposeUseCase: ImageComposeUseCaseProtocol {
    func compose(photoFrame: CIImage, photoBounds: [CGRect], images: [CIImage]) -> AnyPublisher<CIImage, Error> {
        
        return Just(CIImage()).tryMap { $0 }.eraseToAnyPublisher()
    }

    private func crop(with image: CIImage, by frame: CIImage) -> CIImage {
        return CIImage()
    }

    private func resize(with image: CIImage, to size: CGSize) -> CIImage {
        return CIImage()
    }

    private func translation(with image: CIImage, to point: CGPoint) -> CIImage {
        return CIImage()
    }

}
