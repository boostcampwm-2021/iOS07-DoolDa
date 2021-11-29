//
//  ImageComposeUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Combine
import CoreImage
import Foundation

protocol ImageComposeUseCaseProtocol {
    func isComposable(photoFrameType: PhotoFrameType?, numberOfPhotos: Int) -> Bool
    func compose(photoFrameType: PhotoFrameType, images: [CIImage]) -> AnyPublisher<CIImage, Error>
}
