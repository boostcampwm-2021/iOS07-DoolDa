//
//  ImageComposeUseCase.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/08.
//

import Combine
import CoreImage
import Foundation

protocol ImageComposeUseCaseProtocol {
    func compose(photoFrame: PhotoFrameEntity, images: [CIImage]) -> AnyPublisher<CIImage, Error>
}
