//
//  PageRepositoryProtocol.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/08.
//

import Combine
import Foundation

protocol PageRepositoryProtocol {
    func savePage(_ page: PageEntity) -> AnyPublisher<PageEntity, Error>
    func fetchPages(for pair: DDID) -> AnyPublisher<[PageEntity], Error>
}
