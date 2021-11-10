//
//  ImageRepositoryProtocol.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/10.
//

import Combine
import Foundation

protocol ImageRepositoryProtocol {
    func saveLocal(imageData: Data, fileName: String) -> AnyPublisher<URL, Never>
    func saveRemote(user: User, imageData: Data, fileName: String) -> AnyPublisher<URL, Error>
}
