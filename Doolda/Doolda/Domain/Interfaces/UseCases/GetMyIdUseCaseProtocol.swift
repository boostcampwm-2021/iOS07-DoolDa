//
//  GetMyIdUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Combine
import Foundation

protocol GetMyIdUseCaseProtocol {
    func getMyId() -> AnyPublisher<DDID?, Never>
}
