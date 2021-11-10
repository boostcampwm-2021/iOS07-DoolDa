//
//  ImageRepositoryProtocol.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/10.
//

import Combine
import Foundation

protocol ImageRepositoryProtocol {
    func saveLocal(imageData: Data) -> AnyPublisher<URL, Never>
    func saveRemote(user: User, imageData: Data) -> AnyPublisher<URL, Error>
}
