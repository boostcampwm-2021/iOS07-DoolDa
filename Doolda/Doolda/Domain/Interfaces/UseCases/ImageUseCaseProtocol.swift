//
//  ImageUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Combine
import CoreImage
import Foundation

protocol ImageUseCaseProtocol {
    func saveLocal(image: CIImage) -> AnyPublisher<URL, Error>
    func saveRemote(for user: User, localUrl: URL) -> AnyPublisher<URL, Error>
}
