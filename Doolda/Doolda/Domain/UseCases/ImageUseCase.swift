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
