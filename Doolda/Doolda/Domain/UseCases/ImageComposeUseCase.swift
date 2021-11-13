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

    var errorDescription: String? {
        switch self {
        case .numberOfImageMismatched:
            return "선택한 사진의 개수가 올바르지 않습니다."
        case .composingImageFailed:
            return "이미지 합성에 실패했습니다."
        }
    }
}

protocol ImageComposeUseCaseProtocol {
    func isComposable(photoFrameType: PhotoFrameType?, numberOfPhotos: Int) -> Bool
    func compose(photoFrameType: PhotoFrameType, images: [CIImage]) -> AnyPublisher<CIImage, Error>
}

class ImageComposeUseCase: ImageComposeUseCaseProtocol {
    func isComposable(photoFrameType: PhotoFrameType?, numberOfPhotos: Int) -> Bool {
        guard let photoFrame = photoFrameType?.rawValue else { return false }

        return photoFrame.requiredPhotoCount == numberOfPhotos
    }
    
    func compose(photoFrameType: PhotoFrameType, images: [CIImage]) -> AnyPublisher<CIImage, Error> {
        guard let photoFrame = photoFrameType.rawValue,
              let filter = CIFilter(name: "CISourceOverCompositing") else {
            return Fail(error: ImageComposeUseCaseError.composingImageFailed).eraseToAnyPublisher()
        }

        if !self.isComposable(photoFrameType: photoFrameType, numberOfPhotos: images.count) {
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
        var xPosition: CGFloat = 0
        var yPosition: CGFloat = 0
        var width: CGFloat = 0
        var height: CGFloat = 0
        var outputImage: CIImage = image

        if imageRatio < ratio {
            height = image.extent.width / ratio
            width = image.extent.width
            yPosition = (image.extent.height - height) / 2
        } else {
            height = image.extent.height
            width = image.extent.height * ratio
            xPosition = (image.extent.width - width) / 2
        }

        outputImage = outputImage.cropped(to: CGRect(x: xPosition, y: yPosition, width: width, height: height))
        outputImage = outputImage.transformed(by: CGAffineTransform(translationX: -xPosition, y: -yPosition))
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
