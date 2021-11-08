//
//  RawPageRepositoryProtocol.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/08.
//

import Combine
import Foundation

protocol RawPageRepositoryProtocol {
    func saveRawPage(_ rawPage: RawPageEntity) -> AnyPublisher<RawPageEntity, Error>
    func fetchRawPage(for path: String) -> AnyPublisher<RawPageEntity, Error>
}
