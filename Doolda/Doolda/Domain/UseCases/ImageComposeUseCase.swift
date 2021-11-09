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
    case failComposing
}

protocol ImageComposeUseCaseProtocol {
    func compose(photoFrame: CIImage, photoBounds: [CGRect], images: [CIImage]) -> AnyPublisher<CIImage, Error>
}

class ImageComposeUseCase: ImageComposeUseCaseProtocol {
    func compose(photoFrame: CIImage, photoBounds: [CGRect], images: [CIImage]) -> AnyPublisher<CIImage, Error> {
        if photoBounds.count != images.count {
            return Fail(error: ImageComposeUseCaseError.numberOfImageMismatched).eraseToAnyPublisher()
        }

        guard let filter = CIFilter(name: "CISourceOverCompositing") else {
            return Fail(error: ImageComposeUseCaseError.failComposing).eraseToAnyPublisher()
        }

        var outputImage = photoFrame
        for index in 0..<images.count {
            let bound = photoBounds[index]
            let image = images[index]
            let croppedImage = crop(with: image, by: photoFrame)
            let resizedImage = resize(with: croppedImage, to: bound.size)
            let translatedImaged = translation(with: resizedImage, to: bound.origin)

            filter.setDefaults()
            filter.setValue(translatedImaged, forKey: kCIInputImageKey)
            filter.setValue(outputImage, forKey: kCIInputBackgroundImageKey)
            guard let filterOuput = filter.outputImage else {
                return Fail(error: ImageComposeUseCaseError.failComposing).eraseToAnyPublisher()
            }
            outputImage = filterOuput
        }

        return Result<CIImage, Error>.Publisher(outputImage).eraseToAnyPublisher()
    }

    private func crop(with image: CIImage, by frame: CIImage) -> CIImage {
        let imageRatio = image.extent.width / image.extent.height
        let frameRatio = frame.extent.width / frame.extent.height
        var x: CGFloat = 0
        var y: CGFloat = 0
        var width: CGFloat = 0
        var height: CGFloat = 0
        let outputImage: CIImage = image

        if imageRatio < frameRatio {
            let cropRatio = frame.extent.height / frame.extent.width
            height = image.extent.height * cropRatio
            width = image.extent.width
            y = (image.extent.height - height) / 2
        } else {
            height = image.extent.height
            width = image.extent.width * frameRatio
            x = (image.extent.width - width) / 2
        }

        outputImage.cropped(to: CGRect(x: x, y: y, width: width, height: height))
        outputImage.transformed(by: CGAffineTransform(translationX: -x, y: -y))
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
