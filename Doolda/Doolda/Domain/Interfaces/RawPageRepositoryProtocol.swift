//
//  RawPageRepositoryProtocol.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/08.
//

import Combine
import Foundation

protocol RawPageRepositoryProtocol {
    func save(rawPage: RawPageEntity, at folder: String, with name: String) -> AnyPublisher<RawPageEntity, Error>
    func fetch(at folder: String, with name: String) -> AnyPublisher<RawPageEntity, Error>
}
