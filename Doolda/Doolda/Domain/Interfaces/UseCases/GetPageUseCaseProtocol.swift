//
//  GetPageUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Combine
import Foundation

protocol GetPageUseCaseProtocol {
    func getPages(for pair: DDID) -> AnyPublisher<[PageEntity], Error>
}
