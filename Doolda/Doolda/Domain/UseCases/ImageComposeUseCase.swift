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
    case composingImageFailed
}

protocol ImageComposeUseCaseProtocol {
    func compose(photoFrameType: PhotoFrameType, images: [CIImage]) -> AnyPublisher<CIImage, Error>
}

class ImageComposeUseCase: ImageComposeUseCaseProtocol {
    func compose(photoFrameType: PhotoFrameType, images: [CIImage]) -> AnyPublisher<CIImage, Error> {
        guard let photoFrame = photoFrameType.rawValue,
              let filter = CIFilter(name: "CISourceOverCompositing") else {
            return Fail(error: ImageComposeUseCaseError.composingImageFailed).eraseToAnyPublisher()
        }

        if photoFrame.requiredPhotoCount != images.count {
            return Fail(error: ImageComposeUseCaseError.numberOfImageMismatched).eraseToAnyPublisher()
        }

        var outputImage = photoFrame.baseImage
        for index in 0..<photoFrame.requiredPhotoCount {
            let bound = photoFrame.photoBounds[index]
            let image = images[index]
            let croppedImage = crop(with: image, by: bound.width / bound.height)
            let resizedImage = resize(with: croppedImage, to: bound.size)
            let translatePoint = CGPoint(x: bound.origin.x, y: outputImage.extent.height - resizedImage.extent.height - bound.origin.y)
            let translatedImaged = translation(with: resizedImage, to: translatePoint)

            filter.setDefaults()
            filter.setValue(translatedImaged, forKey: kCIInputImageKey)
            filter.setValue(outputImage, forKey: kCIInputBackgroundImageKey)
            guard let filterOuput = filter.outputImage else {
                return Fail(error: ImageComposeUseCaseError.composingImageFailed).eraseToAnyPublisher()
            }
            outputImage = filterOuput
        }

        return Result<CIImage, Error>.Publisher(outputImage).eraseToAnyPublisher()
    }

    private func crop(with image: CIImage, by ratio: CGFloat) -> CIImage {
        let imageRatio = image.extent.width / image.extent.height
        var x: CGFloat = 0
        var y: CGFloat = 0
        var width: CGFloat = 0
        var height: CGFloat = 0
        var outputImage: CIImage = image

        if imageRatio < ratio {
            height = image.extent.width / ratio
            width = image.extent.width
            y = (image.extent.height - height) / 2
        } else {
            height = image.extent.height
            width = image.extent.height * ratio
            x = (image.extent.width - width) / 2
        }

        outputImage = outputImage.cropped(to: CGRect(x: x, y: y, width: width, height: height))
        outputImage = outputImage.transformed(by: CGAffineTransform(translationX: -x, y: -y))
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
