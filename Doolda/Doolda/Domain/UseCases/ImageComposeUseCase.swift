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
        let imageRatio = image.extent.width / image.extent.height
        let frameRatio = frame.extent.width / frame.extent.height
        var outputImage: CIImage

        if imageRatio < frameRatio {
            let cropRatio = frame.extent.height / frame.extent.width
            let height = image.extent.height * cropRatio
            let y = (image.extent.height - height) / 2
            let rect = CGRect(x: 0, y: y, width: image.extent.width, height: height)
        } else {
            let width = image.extent.width * frameRatio
            let x = (image.extent.width - width) / 2
            let rect = CGRect(x: x, y: 0, width: image.extent.width, height: 0)
        }

        return outputImage
    }

    private func resize(with image: CIImage, to size: CGSize) -> CIImage {
        let widthRatio = size.width / image.extent.width
        let heightRatio = size.height / image.extent.height
        let affineTransform = CGAffineTransform(scaleX: widthRatio, y: heightRatio)
        return image.transformed(by: affineTransform)
    }

    private func translation(with image: CIImage, to point: CGPoint) -> CIImage {
        let affineTransform = CGAffineTransform(translationX: point.x, y: point.y)
        return image.transformed(by: affineTransform)
    }

}
